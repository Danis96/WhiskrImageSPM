//
//  WhiskrImageViewModel.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

import Foundation
import Factory
import UIKit
import SwiftUI

public enum FolderName: String {
    case user = "user-profile-images"
    case recipe = "pet-recipe-images"
    case pet = "pet-profile-images"
    case lostAndFound = "lost-and-found-images"
}

@MainActor
public class WhiskrImageViewModel: ObservableObject {

    public init() {}

    @Injected(\WhiskrImageSPM.imageDataSource) private var imageDataSource
    @Injected(\WhiskrImageSPM.selectedImage) private var sharedImageState
    
    public func uploadImage(uiImage: UIImage, folder: FolderName, fileName: String) async -> ResponseModel<ImageModel> {
        do {
            let response: ResponseModel<ImageModel> = try await imageDataSource.uploadImage(
                image: uiImage,
                folder: folder.rawValue, 
                fileName: fileName
            )

            return ResponseModel(data: response.data, error: nil)
        } catch {
            print("Failed to upload image: \(error.localizedDescription)")
            return ResponseModel(data: nil, error: error.localizedDescription)
        }
    }
    
    // Access the shared image state
    public var selectedImage: Binding<Image?> {
        Binding(
            get: { self.sharedImageState.image },
            set: { self.sharedImageState.image = $0 }
        )
    }
}
