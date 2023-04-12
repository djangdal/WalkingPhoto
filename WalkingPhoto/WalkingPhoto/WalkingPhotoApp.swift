//
//  WalkingPhotoApp.swift
//  WalkingPhoto
//
//  Created by David Jangdal on 2023-04-06.
//

import SwiftUI
import CoreLocation
import CosyNetwork

@main
struct WalkingPhotoApp: App {
    let mainViewModel: MainViewModel

    init() {
        let decoder = JSONDecoder()
        let dispatcher = APIDispatcher(decoder: decoder)
        let flickrService = FlickrService(dispatcher: dispatcher)
        let locationManager = CLLocationManager()
        let locationService = LocationService(locationManager: locationManager)
        let photoService = PhotoService(flickrService: flickrService)
        mainViewModel = MainViewModel(photoService: photoService, locationService: locationService)
    }

    var body: some Scene {
        WindowGroup {
            MainView(viewModel: mainViewModel)
        }
    }
}
