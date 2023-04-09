//
//  WalkingPhotoTests.swift
//  WalkingPhotoTests
//
//  Created by David Jangdal on 2023-04-06.
//

import XCTest
import CosyNetwork
import Combine
import CoreLocation
@testable import WalkingPhoto

final class WalkingPhotoTests: XCTestCase {

    func testCreateUrlFromPhoto() {
        let photo = PhotoSearchResponse.Photos.Photo(id: "id",
                                                     owner: "owner",
                                                     secret: "secret",
                                                     server: "server",
                                                     farm: 1,
                                                     title: "title",
                                                     ispublic: 2,
                                                     isfriend: 3,
                                                     isfamily: 4)
        XCTAssertEqual(photo.imageUrl?.absoluteString, "https://live.staticflickr.com/server/id_secret_w.jpg")
    }

    func testCreating3Locations() {
        let expectation = XCTestExpectation()
        let flickerService = MockFlickerService()
        let locationService = MockLocationService()
        let viewModel = MainViewModel(flickerService: flickerService, locationService: locationService)

        locationService.locationSubject.send(.init(latitude: 0, longitude: 0))
        locationService.locationSubject.send(.init(latitude: 0, longitude: 1))
        locationService.locationSubject.send(.init(latitude: 0, longitude: 2))
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            XCTAssertEqual(viewModel.imageCards.count, 3)
            XCTAssertEqual(viewModel.imageCards[0].url.absoluteString, "http://example.com")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

}

private final class MockFlickerService: FlickrServiceProtocol {
    func searchForPhotoURL(at location: CLLocation) async throws -> URL {
        URL(string: "http://example.com")!
    }
}

private final class MockLocationService: LocationServiceProtocol {
    var locationSubject = CurrentValueSubject<CLLocation?, Never>(nil)
    var location: CLLocation? = nil
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationSubject.compactMap {$0 }.eraseToAnyPublisher()
    }

    func requestLocationPermission() {}
    func startUpdatingLocation() {}
    func stopUpdatingLocation() {}
}
