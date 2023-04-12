//
//  MainView.swift
//  WalkingPhoto
//
//  Created by David Jangdal on 2023-04-06.
//

import SwiftUI
import CoreLocation

struct MainView<ViewModel: MainViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        switch viewModel.trackingMode {
        case .notStarted: startButtonView
        case .tracking, .paused: photosView
        }
    }

    var startButtonView: some View {
        HStack {
            Button(action: viewModel.didTapStart) {
                Text("Start tracking")
                    .padding(20)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
        }
    }

    var stopButton: some View {
        HStack {
            Spacer()
            Button(action: viewModel.trackingMode == .tracking ? viewModel.didTapStop: viewModel.didTapResume) {
                Text(viewModel.trackingMode == .tracking ? "Stop" : "Resume")
                    .padding(vertical: 4, horizontal: 12)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(6)
            }
            .padding(trailing: 10)
        }
    }

    var photosView: some View {
        VStack {
            stopButton
            ScrollView {
                VStack {
                    ForEach(viewModel.imageCards) { imageCard in
                        ImageCardView(imageData: imageCard)
                    }
                }
                .padding(0)
            }
            .background(Color.black.opacity(0.1))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MockViewModel())
    }
}

private class MockViewModel: MainViewModelProtocol {
    var imageCards: [ImageCardViewData] = [.init(location: .init(),
                                                 photoService: MockPhotoService()),
                                           .init(location: .init(),
                                                 photoService: MockPhotoService()),
                                           .init(location: .init(),
                                                 photoService: MockPhotoService())]
    var trackingMode: TrackingMode = .tracking
    func didTapStart() {}
    func didTapStop() {}
    func didTapResume() {}
}

private class MockPhotoService: PhotoServiceProtocol {
    func url(for location: CLLocation) async throws -> URL {
        URL(string: "https://picsum.photos/200/300")!
    }
}
