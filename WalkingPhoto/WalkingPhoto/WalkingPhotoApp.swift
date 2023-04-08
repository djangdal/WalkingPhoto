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
        let flickerService = FlickrService(dispatcher: dispatcher)
        let locationManager = CLLocationManager()
        let locationService = LocationService(locationManager: locationManager)
        mainViewModel = MainViewModel(flickerService: flickerService, locationService: locationService)
    }

    var body: some Scene {
        WindowGroup {
            MainView(viewModel: mainViewModel)
        }
    }
}
