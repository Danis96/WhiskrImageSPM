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
import PhotosUI

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
    @Published public var isLoading: Bool = false
    
    public func uploadImage(uiImage: UIImage, folder: FolderName, fileName: String) async -> ResponseModel<ImageModel> {
        isLoading = true
        defer {
            isLoading = false
        }
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
    
    public func processAndUploadImage(from item: PhotosPickerItem, folder: FolderName) async throws -> ImageModel {
        // Load the data from PhotosPickerItem
        guard let data = try await item.loadTransferable(type: Data.self) else {
            print("PhotoPicker: Failed to load data")
            throw URLError(.badServerResponse)
        }
        
        // Convert data to UIImage
        guard let uiImage = UIImage(data: data) else {
            print("PhotoPicker: Failed to create UIImage")
            throw URLError(.cannotDecodeContentData)
        }
        
        // Create initial SwiftUI Image
        let localImage = Image(uiImage: uiImage)
        
        // Upload the image
        let response = try await uploadImage(
            uiImage: uiImage,
            folder: folder,
            fileName: UUID().uuidString
        )
        
        // Return the appropriate image
        if let imageData = response.data, let imageUrl = imageData.url {
            return imageData
        } else {
            print("PhotoPicker: Failed to upload image")
            return ImageModel()
        }
    }
    
    public var selectedImage: Binding<ImageModel?> {
        Binding(
            get: { self.sharedImageState.image },
            set: { self.sharedImageState.image = $0 }
        )
    }
}
