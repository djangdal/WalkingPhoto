//
//  MainViewModel.swift
//  WalkingPhoto
//
//  Created by David Jangdal on 2023-04-06.
//

import Foundation
import CoreLocation
import Combine

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

    private let flickerService: FlickrServiceProtocol
    private let locationService: LocationServiceProtocol
    private var subscriptions = Set<AnyCancellable>()
    private var locationsSubject = CurrentValueSubject<[CLLocation], Never>([])
    
    init(flickerService: FlickrServiceProtocol, locationService: LocationServiceProtocol) {
        self.flickerService = flickerService
        self.locationService = locationService
        subscribeToPhotoLocations()
        subscribeToLocationUpdates()
    }
}

private extension MainViewModel {
    func subscribeToPhotoLocations() {
        locationsSubject
            .receive(on: RunLoop.main)
            .sink { locations in
                Task { @MainActor in
                    try await withThrowingTaskGroup(of: ImageCardViewData.self) { group in
                        locations.forEach { location in
                            group.addTask {
                                let url = try await self.flickerService.searchForPhotoURL(at: location)
                                return ImageCardViewData(location: location, url: url)
                            }
                        }

                        self.imageCards = try await group
                            .reduce(into: [ImageCardViewData]()) { $0.append($1) }
                            .sorted { $0.location.timestamp > $1.location.timestamp}
                    }
                }
            }.store(in: &subscriptions)
    }

    func subscribeToLocationUpdates() {
        locationService.locationPublisher
            .filter { [weak self] location in
                guard let distance = self?.locationsSubject.value.first?.distance(from: location) else {
                    return true
                }
                return distance > 100
            }
            .sink(receiveValue: { [weak self] location in
                self?.locationsSubject.value.insert(location, at: 0)
            })
            .store(in: &subscriptions)
    }
}

extension MainViewModel: MainViewModelProtocol {
    func didTapStart() {
        trackingMode = .tracking
        locationService.requestLocationPermission()
        locationService.startUpdatingLocation()
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

