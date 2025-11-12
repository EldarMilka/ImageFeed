////
////  ImageFeedTests.swift
////  ImageFeedTests
////
////  Created by Эльдар Милкаманавичюс on 05.10.2025.
////
//
//@testable import ImageFeed
//import XCTest
//
//final class ImagesListServiceTests: XCTestCase {
//    
//    func testFetchPhotos() {
//        let service = ImagesListService.shared
//        service.clean() // Очищаем перед тестом
//        
//        let expectation = self.expectation(description: "Wait for Notification")
//        
//        var observer: NSObjectProtocol?
//        observer = NotificationCenter.default.addObserver(
//            forName: ImagesListService.didChangeNotification,
//            object: service,
//            queue: .main) { _ in
//                expectation.fulfill()
//                if let observer = observer {
//                    NotificationCenter.default.removeObserver(observer)
//                }
//            }
//        
//        service.fetchPhotosNextPage()
//        wait(for: [expectation], timeout: 10)
//        
//        XCTAssertTrue(service.photos.count > 0, "Должны быть загружены фото")
//    }
//    
//    func testChangeLike() {
//        let service = ImagesListService.shared
//        
//        // Сначала нужно загрузить фото
//        let fetchExpectation = self.expectation(description: "Wait for fetch")
//        
//        var fetchObserver: NSObjectProtocol?
//        fetchObserver = NotificationCenter.default.addObserver(
//            forName: ImagesListService.didChangeNotification,
//            object: service,
//            queue: .main) { _ in
//                fetchExpectation.fulfill()
//                if let observer = fetchObserver {
//                    NotificationCenter.default.removeObserver(observer)
//                }
//            }
//        
//        service.fetchPhotosNextPage()
//        wait(for: [fetchExpectation], timeout: 10)
//        
//        guard let firstPhoto = service.photos.first else {
//            XCTFail("Нет фото для тестирования лайков")
//            return
//        }
//        
//        let likeExpectation = self.expectation(description: "Wait for like")
//        let newLikeState = !firstPhoto.isLiked
//        
//        service.changeLike(photoId: firstPhoto.id, isLike: newLikeState) { result in
//            switch result {
//            case .success:
//                // Проверяем что состояние изменилось
//                if let updatedPhoto = service.photos.first(where: { $0.id == firstPhoto.id }) {
//                    XCTAssertEqual(updatedPhoto.isLiked, newLikeState, "Состояние лайка должно измениться")
//                }
//            case .failure(let error):
//                XCTFail("Ошибка при изменении лайка: \(error)")
//            }
//            likeExpectation.fulfill()
//        }
//        
//        wait(for: [likeExpectation], timeout: 10)
//    }
//}
//
//// MARK: - Network Error Tests
//// MARK: - Network Error Tests
//final class NetworkErrorTests: XCTestCase {
//    
//    func testNetworkErrorCases() {
//        // Test urlSessionError
//        let urlError = NetworkError.urlSessionError
//        XCTAssertNotNil(urlError)
//        
//        // Test httpStatusCode
//        let statusCodeError = NetworkError.httpStatusCode(404)
//        XCTAssertNotNil(statusCodeError)
//        
//        // Test urlRequestError
//        let testError = NSError(domain: "test", code: 123, userInfo: nil)
//        let requestError = NetworkError.urlRequestError(testError)
//        XCTAssertNotNil(requestError)
//        
//        // Test noData
//        let noDataError = NetworkError.noData
//        XCTAssertNotNil(noDataError)
//    }
//    
//    func testNetworkErrorEquality() {
//        let error1 = NetworkError.httpStatusCode(404)
//        let error2 = NetworkError.httpStatusCode(500)
//        let error3 = NetworkError.noData
//        
//        // Они не должны быть равны, так как разные case
//        XCTAssertNotEqual(error1.localizedDescription, error2.localizedDescription)
//        XCTAssertNotEqual(error1.localizedDescription, error3.localizedDescription)
//    }
//}
//
//// MARK: - Photo Model Tests
//final class PhotoModelTests: XCTestCase {
//    
//    func testPhotoInitialization() {
//        let photo = Photo(
//            id: "test-id",
//            size: CGSize(width: 100, height: 200),
//            createdAt: Date(),
//            welcomeDescription: "Test Description",
//            thumbImageURL: "https://example.com/thumb.jpg",
//            largeImageURL: "https://example.com/large.jpg",
//            fullImageUrl: "https://example.com/full.jpg",
//            isLiked: true
//        )
//        
//        XCTAssertEqual(photo.id, "test-id")
//        XCTAssertEqual(photo.size.width, 100)
//        XCTAssertEqual(photo.size.height, 200)
//        XCTAssertNotNil(photo.createdAt)
//        XCTAssertEqual(photo.welcomeDescription, "Test Description")
//        XCTAssertEqual(photo.thumbImageURL, "https://example.com/thumb.jpg")
//        XCTAssertEqual(photo.largeImageURL, "https://example.com/large.jpg")
//        XCTAssertEqual(photo.fullImageUrl, "https://example.com/full.jpg")
//        XCTAssertTrue(photo.isLiked)
//    }
//    
//    func testPhotoWithoutOptionalValues() {
//        let photo = Photo(
//            id: "test-id-2",
//            size: CGSize(width: 300, height: 400),
//            createdAt: nil,
//            welcomeDescription: nil,
//            thumbImageURL: "https://example.com/thumb2.jpg",
//            largeImageURL: "https://example.com/large2.jpg",
//            fullImageUrl: "https://example.com/full2.jpg",
//            isLiked: false
//        )
//        
//        XCTAssertEqual(photo.id, "test-id-2")
//        XCTAssertEqual(photo.size.width, 300)
//        XCTAssertEqual(photo.size.height, 400)
//        XCTAssertNil(photo.createdAt)
//        XCTAssertNil(photo.welcomeDescription)
//        XCTAssertEqual(photo.thumbImageURL, "https://example.com/thumb2.jpg")
//        XCTAssertEqual(photo.largeImageURL, "https://example.com/large2.jpg")
//        XCTAssertEqual(photo.fullImageUrl, "https://example.com/full2.jpg")
//        XCTAssertFalse(photo.isLiked)
//    }
//}
