//
//  ImagesListPresenterTests.swift
//  ImageFeedTests
//
//  Created by Эльдар Милкаманавичюс on 07.11.2025.
import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    // MARK: - Test Doubles
    
    class MockImagesListViewController: ImagesListViewControllerProtocol {
        var presenter: ImagesListPresenterProtocol?
        
        var updateTableViewAnimatedCalled = false
        var updateTableViewAnimatedOldCount: Int?
        var updateTableViewAnimatedNewCount: Int?
        
        var showErrorAlertCalled = false
        var showErrorAlertTitle: String?
        var showErrorAlertMessage: String?
        
        func updateTableViewAnimated(oldCount: Int, newCount: Int) {
            updateTableViewAnimatedCalled = true
            updateTableViewAnimatedOldCount = oldCount
            updateTableViewAnimatedNewCount = newCount
        }
        
        func showGradientForCell(at indexPath: IndexPath, in cell: ImagesListCell) {}
        func hideGradientForCell(at indexPath: IndexPath) {}
        func reloadRows(at indexPaths: [IndexPath]) {}
        
        func showErrorAlert(title: String, message: String) {
            showErrorAlertCalled = true
            showErrorAlertTitle = title
            showErrorAlertMessage = message
        }
        
        func initializeAfterPresenterSetup() {}
    }
    
    class MockImagesListService: ImagesListServiceProtocol {
        var photos: [Photo] = []
        var fetchPhotosNextPageCalled = false
        var changeLikeCalled = false
        var changeLikePhotoId: String?
        var changeLikeIsLike: Bool?
        
        func fetchPhotosNextPage() {
            fetchPhotosNextPageCalled = true
        }
        
        func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
            changeLikeCalled = true
            changeLikePhotoId = photoId
            changeLikeIsLike = isLike
            
            // Симулируем успешное выполнение
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Properties
    
    private var presenter: ImagesListPresenter!
    private var mockView: MockImagesListViewController!
    private var mockService: MockImagesListService!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        mockView = MockImagesListViewController()
        mockService = MockImagesListService()
        presenter = ImagesListPresenter(imagesListService: mockService)
        presenter.view = mockView
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testViewDidLoadCallsFetchPhotosNextPage() {
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled, "viewDidLoad должен вызывать fetchPhotosNextPage")
    }
    
    func testPhotosCountReturnsCorrectValue() {
        // Given
        let testPhotos = [
            Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test 1", thumbImageURL: "", largeImageURL: "", fullImageUrl: "", isLiked: false),
            Photo(id: "2", size: CGSize(width: 200, height: 200), createdAt: Date(), welcomeDescription: "Test 2", thumbImageURL: "", largeImageURL: "", fullImageUrl: "", isLiked: true)
        ]
        
        // When
        // Устанавливаем фото в сервис и принудительно обновляем презентер
        mockService.photos = testPhotos
        presenter.handlePhotosUpdate() // Обновляем данные в презентере
        
        let count = presenter.photosCount
        
        // Then
        XCTAssertEqual(count, 2, "photosCount должен возвращать корректное количество фото")
    }
    
    func testPhotoAtIndexReturnsCorrectPhoto() {
        // Given
        let testPhoto = Photo(id: "test-id", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test", thumbImageURL: "", largeImageURL: "", fullImageUrl: "", isLiked: true)
        
        // When
        mockService.photos = [testPhoto]
        presenter.handlePhotosUpdate() // Обновляем данные в презентере
        
        let photo = presenter.photo(at: 0)
        
        // Then
        XCTAssertEqual(photo?.id, "test-id", "photo(at:) должен возвращать корректное фото")
        XCTAssertTrue(photo?.isLiked == true, "photo(at:) должен возвращать фото с правильным состоянием лайка")
    }
    
    func testPhotoAtIndexReturnsNilForInvalidIndex() {
        // Given
        mockService.photos = []
        
        // When
        let photo = presenter.photo(at: 5)
        
        // Then
        XCTAssertNil(photo, "photo(at:) должен возвращать nil для невалидного индекса")
    }
    
    func testFetchPhotosNextPageCallsService() {
        // When
        presenter.fetchPhotosNextPage()
        
        // Then
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled, "fetchPhotosNextPage должен вызывать сервис")
    }
    
    func testChangeLikeCallsServiceWithCorrectParameters() {
        // When
        presenter.changeLike(photoId: "test-photo-id", isLike: true)
        
        // Then
        XCTAssertTrue(mockService.changeLikeCalled, "changeLike должен вызывать сервис")
        XCTAssertEqual(mockService.changeLikePhotoId, "test-photo-id", "changeLike должен передавать правильный photoId")
        XCTAssertEqual(mockService.changeLikeIsLike, true, "changeLike должен передавать правильное состояние лайка")
    }
    
    func testCalculateCellHeightReturnsCorrectValue() {
        // Given
        let photo = Photo(
            id: "test",
            size: CGSize(width: 1000, height: 800),
            createdAt: Date(),
            welcomeDescription: "Test",
            thumbImageURL: "",
            largeImageURL: "",
            fullImageUrl: "",
            isLiked: false
        )
        let tableViewWidth: CGFloat = 375
        
        // When
        let height = presenter.calculateCellHeight(for: photo, tableViewWidth: tableViewWidth)
        
        // Then
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let expectedHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        XCTAssertEqual(height, expectedHeight, accuracy: 0.1, "calculateCellHeight должен возвращать корректную высоту")
    }
    
    func testHandlePhotosUpdateCallsViewUpdate() {
        // Given
        let testPhotos = [
            Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "Test 1", thumbImageURL: "", largeImageURL: "", fullImageUrl: "", isLiked: false)
        ]
        
        // When
        // Вместо нотификации напрямую вызываем handlePhotosUpdate
        mockService.photos = testPhotos
        presenter.handlePhotosUpdate() // Вызываем метод напрямую
        
        // Then
        XCTAssertTrue(mockView.updateTableViewAnimatedCalled, "При обновлении фото должен вызываться updateTableViewAnimated")
        XCTAssertEqual(mockView.updateTableViewAnimatedOldCount, 0, "Старое количество должно быть 0")
        XCTAssertEqual(mockView.updateTableViewAnimatedNewCount, 1, "Новое количество должно быть 1")
    }
}
