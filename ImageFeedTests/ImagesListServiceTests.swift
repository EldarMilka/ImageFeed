//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Эльдар Милкаманавичюс on 05.10.2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListServiceTests: XCTestCase {
    
    func testFetchPhotos() {
        let stubNetworkService = StubNetworkService()
        let service = ImagesListService(networkService: stubNetworkService)
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(service.photos.count, 10)
        XCTAssertTrue(stubNetworkService.fetchDataCalled)
    }
}

final class StubNetworkService: NetworkServiceProtocol{
    var fetchDataCalled = false
    func fetchData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        fetchDataCalled = true
        
        let photos = (0..<10).map { index in
                    Photo(
                        id: "\(index)",
                        size: CGSize(width: 100, height: 100),
                        createdAt: nil,
                        welcomeDescription: nil,
                        thumbImageURL: "",
                        largeImageURL: "",
                        isLiked: false
                        )
                }

                // Преобразуем [Photo] в Data, чтобы соответствовать JSON, который ожидает ImagesListService
        let photoResults = photos.map { photo in
            PhotoResult(id: photo.id,
                        createdAt: nil,
                        updatedAt: "2025-01-01T00:00:00Z",
                        width: Int(photo.size.width),
                        height: Int(photo.size.height),
                        color: "#FFFFFF",
                        blurHash: "",
                        likes: 0,
                        likedByUser: photo.isLiked,
                        description: photo.welcomeDescription,
                        urls: UrlsResult(
                            raw: nil,
                            full: nil,
                            regular: photo.largeImageURL,
                            small: nil,
                            thumb: photo.thumbImageURL
                        )
            )}
                let data = try! JSONEncoder().encode(photoResults)

                DispatchQueue.main.async {
                    completion(.success(data))
                }
            }
        }
