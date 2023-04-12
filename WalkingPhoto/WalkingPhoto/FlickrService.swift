//
//  FlickrService.swift
//  WalkingPhoto
//
//  Created by David Jangdal on 2023-04-06.
//

import Foundation
import CosyNetwork
import CoreLocation

protocol FlickrServiceProtocol: AnyObject {
    func searchForPhotoURL(at location: CLLocation) async throws -> [PhotoSearchResponse.Photos.Photo] 
}

actor FlickrService: FlickrServiceProtocol {
    private let dispatcher: APIDispatcher

    init(dispatcher: APIDispatcher) {
        self.dispatcher = dispatcher
    }

    func searchForPhotoURL(at location: CLLocation) async throws -> [PhotoSearchResponse.Photos.Photo] {
        let request = PhotoSearchRequest(latitude: location.coordinate.latitude,
                                         longitude: location.coordinate.longitude,
                                         radius: 5)
        let response = try await dispatcher.dispatch(request)
        return response.0.photos.photo
    }
}

fileprivate struct PhotoSearchRequest: APIDecodableRequest {
    typealias ResponseBodyType = PhotoSearchResponse
    typealias ErrorBodyType = PhotoSearchError

    var baseURLPath: String = "https://www.flickr.com"
    var path: String = "/services/rest/"
    var latitude: Double
    var longitude: Double
    var radius: Double

    var method: CosyNetwork.HTTPMethod = .get
    var successStatusCodes: [CosyNetwork.HTTPStatusCode] = [.ok]
    var failingStatusCodes: [CosyNetwork.HTTPStatusCode] = [.badRequest]
    var requestHeaders: [String : String]?
    var queryParameters: [String : String]? {
        ["method": "flickr.photos.search",
         "api_key": "2d994e11ccc40e387788dc8428a2e793",
         "format": "json",
         "nojsoncallback": "1",
         "lat": "\(latitude)",
         "lon": "\(longitude)",
         "radius": "\(radius)"]
    }
}

struct PhotoSearchError: Error, Decodable {
}

struct PhotoSearchResponse: Decodable {
    let photos: Photos

    struct Photos: Decodable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: Int
        let photo: [Photo]

        struct Photo: Decodable {
            let id: String
            let owner: String
            let secret: String
            let server: String
            let farm: Int
            let title: String
            let ispublic: Int
            let isfriend: Int
            let isfamily: Int
        }
    }
}
