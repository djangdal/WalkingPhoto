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
        case .tracking: photosView
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

    var photosView: some View {
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MockViewModel())
    }
}

private class MockViewModel: MainViewModelProtocol {
    var imageCards: [ImageCardViewData] = []
    var trackingMode: TrackingMode = .tracking
    func didTapStart() {}
}
