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
    func searchForPhoto(at coordinate: CLLocationCoordinate2D) async throws -> PhotoSearchResponse
}

final class FlickrService: FlickrServiceProtocol {

    private let dispatcher: APIDispatcher

    init(dispatcher: APIDispatcher) {
        self.dispatcher = dispatcher
    }

    func searchForPhoto(at coordinate: CLLocationCoordinate2D) async throws -> PhotoSearchResponse {
        let request = PhotoSearchRequest(latitude: coordinate.latitude,
                                         longitude: coordinate.longitude,
                                         radius: 0.1)
        let response = try await dispatcher.dispatch(request)
        return response.0
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

            var imageUrl: URL? {
                let urlString = "https://live.staticflickr.com/\(server)/\(id)_\(secret)_w.jpg"
                return URL(string: urlString)
            }
        }
    }
}
