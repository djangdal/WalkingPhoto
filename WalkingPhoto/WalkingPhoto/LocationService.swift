//
//  LocationService.swift
//  WalkingPhoto
//
//  Created by David Jangdal on 2023-04-06.
//

import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    var location: CLLocation? { get }
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }
    func requestLocationPermission()
    func startUpdatingLocation()
}

final class LocationService: NSObject {
    private let locationManager: CLLocationManager
    private var locationSubject: CurrentValueSubject<CLLocation?, Never>

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        locationSubject = CurrentValueSubject(nil)
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
    }
}

extension LocationService: LocationServiceProtocol {
    var location: CLLocation? {
        locationManager.location
    }

    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationSubject.compactMap { $0 }.eraseToAnyPublisher()
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { locationSubject.send($0) }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
}
