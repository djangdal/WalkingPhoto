//
//  WalkingPhotoTests.swift
//  WalkingPhotoTests
//
//  Created by David Jangdal on 2023-04-06.
//

import XCTest
import CosyNetwork
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

}
