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
        let photo = PhotoParameters(id: "id",
                                    server: "server",
                                    secret: "secret")
        XCTAssertEqual(photo.imageUrl?.absoluteString, "https://live.staticflickr.com/server/id_secret_w.jpg")
    }

    func testCreating3Locations_andCheckLastIsFirst() {
        let expectation = XCTestExpectation()
        let photoService = MockPhotoService()
        let locationService = MockLocationService()
        let viewModel = MainViewModel(photoService: photoService, locationService: locationService)

        locationService.locationSubject.send(.init(latitude: 0, longitude: 0))
        locationService.locationSubject.send(.init(latitude: 0, longitude: 1))
        locationService.locationSubject.send(.init(latitude: 0, longitude: 2))
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            XCTAssertEqual(viewModel.imageCards.count, 3)
            XCTAssertEqual(viewModel.imageCards[0].location.coordinate.longitude, 2)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

}

private final class MockPhotoService: PhotoServiceProtocol {
    func url(for location: CLLocation) async throws -> URL {
        return URL(string: "https://picsum.photos/200/300")!
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
