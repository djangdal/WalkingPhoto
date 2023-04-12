//
//  ImageCardView.swift
//  WalkingPhoto
//
//  Created by David Jangdal on 2023-04-07.
//

import Foundation
import SwiftUI
import CoreLocation

struct ImageCardViewData: Identifiable {
    let id = UUID()
    let location: CLLocation
    let photoService: PhotoServiceProtocol
}

struct ImageCardView: View {
    let imageData: ImageCardViewData
    @State private var url: URL? = nil

    @ViewBuilder var imageView: some View {
        AsyncImage(url: url, content: { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        }, placeholder: {
            Color.black.opacity(0.4)
        })
    }

    var body: some View {
        VStack {
            Color.clear
            // This is a neat little hack to be able to scale image with fill without stretching other elements outside of screen
                .background(
                    imageView
                )
                .frame(height: 240)
                .cornerRadius(14)
                .padding(10)
            HStack {
                Text(imageData.location.timestamp.ISO8601Format())
                    .foregroundColor(.black)
                    .font(.body)
                Spacer()
                VStack {
                    Text("lat: \(imageData.location.coordinate.latitude)")
                        .foregroundColor(.black)
                        .font(.body)
                    Text("lon: \(imageData.location.coordinate.latitude)")
                        .foregroundColor(.black)
                        .font(.body)
                }
            }
            .padding(horizontal: 10)
            .padding(bottom: 10)
        }
        .background(Color.white)
        .cornerRadius(14)
        .padding(10)
        .onAppear {
            Task {
                do {
                    self.url = try await imageData.photoService.url(for: imageData.location)
                } catch {
                    print("Could not get image for location \(error)")
                    //Here we could show error to user, show some error image, try again etc. Need to discuss with product team which option to take
                }
            }
        }
    }
}

struct ImageCardView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCardView(imageData: ImageCardViewData(location: .init(),
                                                   photoService: MockPhotoService()))
    }

    private class MockPhotoService: PhotoServiceProtocol {
        func url(for location: CLLocation) async throws -> URL {
            URL(string: "https://picsum.photos/200/300")!
        }
    }
}
