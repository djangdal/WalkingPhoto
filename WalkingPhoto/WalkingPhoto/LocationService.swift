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
    func stopUpdatingLocation()
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
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            break;
        case .restricted, .denied:
            // Here we could send user to settings if we want
            break;
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            break;
        case .authorizedAlways:
            break;
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { locationSubject.send($0) }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
}
