//
//  PhotoService.swift
//  WalkingPhoto
//
//  Created by David Jangdal on 2023-04-12.
//

import Foundation
import CoreLocation

enum PhotoServiceError: Error {
    case searchHasNoUniqueImage
    case couldNotConstructURL
}

protocol PhotoServiceProtocol {
    func url(for location: CLLocation) async throws -> URL
}

struct PhotoParameters: Equatable {
    let id: String
    let server: String
    let secret: String

    var imageUrl: URL? {
        let urlString = "https://live.staticflickr.com/\(server)/\(id)_\(secret)_w.jpg"
        return URL(string: urlString)
    }
}

actor PhotoService {
    private let flickrService: FlickrServiceProtocol
    private var photosUsed = [PhotoParameters]()

    init(flickrService: FlickrServiceProtocol) {
        self.flickrService = flickrService
    }
}

extension PhotoService: PhotoServiceProtocol {
    func url(for location: CLLocation) async throws -> URL {
        let photos = try await flickrService.searchForPhotoURL(at: location)

        let uniquePhoto = photos.map {
            PhotoParameters(id: $0.id, server: $0.server, secret: $0.secret)
        }.first {
            !photosUsed.contains($0)
        }

        guard let newPhoto = uniquePhoto else {
            throw PhotoServiceError.searchHasNoUniqueImage
            // If no unique image exist(one that hasn't been used before)
            // We could perhaps do a new search with different parameters, or show something else
            // Check with product what would be best decision
        }

        guard let url = newPhoto.imageUrl else {
            throw PhotoServiceError.couldNotConstructURL
        }

        photosUsed.append(newPhoto)
        return url
    }
}
