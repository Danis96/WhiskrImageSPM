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

public enum ImageFolderName: String {
    case userProfile = "user-profile-images"
    case recipeImage = "pet-recipe-images"
    case petProfile = "pet-profile-images"
    case lostAndFoundImage = "lost-and-found-images"
}

public enum ImageFolderType: String {
    case user = "user"
    case pet = "pet"
    case recipe = "recipe"
}

@MainActor
public class WhiskrImageViewModel: ObservableObject {

    public init() {}

    @Injected(\WhiskrImageSPM.imageDataSource) private var imageDataSource
    @Injected(\WhiskrImageSPM.selectedImage) private var sharedImageState
    @Published public var isLoading: Bool = false
    
    public func uploadImage(uiImage: UIImage, folder: ImageFolderName, fileName: String) async -> ResponseModel<ImageModel> {
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
            print("Response: \(response.data?.url ?? "")")
            print("Response: \(response.data?.imageId ?? "")")
            
            return ResponseModel(data: response.data, error: nil)
        } catch {
            print("Failed to upload image: \(error.localizedDescription)")
            return ResponseModel(data: nil, error: error.localizedDescription)
        }
    }
    
    public func processImage(from item: PhotosPickerItem) async throws -> ImageModel {
        // Load the data from PhotosPickerItem
        guard let data: Data = try await item.loadTransferable(type: Data.self) else {
            print("PhotoPicker: Failed to load data")
            throw URLError(.badServerResponse)
        }
        
        // Convert data to UIImage
        guard let uiImage: UIImage = UIImage(data: data) else {
            print("PhotoPicker: Failed to create UIImage")
            throw URLError(.cannotDecodeContentData)
        }
        
        // Create initial SwiftUI Image and return processed image model
        let localImage: Image = Image(uiImage: uiImage)
        return ImageModel(imageProcessed: uiImage)
    }
    
    public func processAndUploadImage(from item: PhotosPickerItem, folder: ImageFolderName) async throws -> ImageModel {
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
    
    public func deleteImage(imageID: String, type: ImageFolderName, typeID: String) async -> ResponseModel<String> {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let response: ResponseModel<String> = try await imageDataSource.deleteImage(imageId: imageID, type: setFolderTypeBasedOnFolderName(for: type), typeId: typeID)
            return ResponseModel(data: response.data, error: nil)
        } catch {
            print("Failed to delete image: \(error.localizedDescription)")
            return ResponseModel(data: nil, error: error.localizedDescription)
        }
    }
    
    private func setFolderTypeBasedOnFolderName(for type: ImageFolderName) -> String {
        switch type {
            case .userProfile:
                return ImageFolderType.user.rawValue
            case .recipeImage:
                return ImageFolderType.recipe.rawValue
            case .petProfile:
                return ImageFolderType.pet.rawValue
            case .lostAndFoundImage:
                return ""
        }
    }
}
