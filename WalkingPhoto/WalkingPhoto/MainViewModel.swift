//
//  MainViewModel.swift
//  WalkingPhoto
//
//  Created by David Jangdal on 2023-04-06.
//

import Foundation
import CoreLocation
import Combine
import UIKit

enum TrackingMode {
    case notStarted
    case tracking
    case paused
}

protocol MainViewModelProtocol: ObservableObject {
    var imageCards: [ImageCardViewData] { get }
    var trackingMode: TrackingMode { get }
    func didTapStart()
    func didTapStop()
    func didTapResume()
}

final class MainViewModel {
    @Published var imageCards: [ImageCardViewData] = []
    @Published var trackingMode: TrackingMode = .notStarted

    private let photoService: PhotoServiceProtocol
    private let locationService: LocationServiceProtocol
    private var locationsCancellable: AnyCancellable?
    private var photosCancellable: AnyCancellable?
    private var locationsSubject = CurrentValueSubject<[CLLocation], Never>([])

    init(photoService: PhotoServiceProtocol, locationService: LocationServiceProtocol) {
        self.photoService = photoService
        self.locationService = locationService
        subscribeToPhotoUpdates()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    @objc func didEnterBackground() {
        photosCancellable?.cancel()
    }

    @objc func didEnterForeground() {
        subscribeToPhotoUpdates()
    }
}

private extension MainViewModel {
    func subscribeToPhotoUpdates() {
        photosCancellable = locationsSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] locations in
                guard let self = self else { return }
                let new = locations
                    .dropLast(imageCards.count)
                    .map {
                    ImageCardViewData(location: $0, photoService: self.photoService)
                }
                imageCards.insert(contentsOf: new, at: 0)
            }
    }

    func subscribeToLocationUpdates() {
        locationsCancellable = locationService.locationPublisher
            .filter { [weak self] location in
                guard let distance = self?.locationsSubject.value.first?.distance(from: location) else {
                    return true
                }
                return distance > 100
            }
            .sink(receiveValue: { [weak self] location in
                guard let self = self else { return }
                self.locationsSubject.value.insert(location, at: 0)
            })
    }
}

extension MainViewModel: MainViewModelProtocol {
    func didTapStart() {
        trackingMode = .tracking
        locationService.requestLocationPermission()
        locationService.startUpdatingLocation()
        subscribeToLocationUpdates()
    }

    func didTapStop() {
        trackingMode = .paused
        locationService.stopUpdatingLocation()
    }

    func didTapResume() {
        trackingMode = .tracking
        locationService.startUpdatingLocation()
    }
}

