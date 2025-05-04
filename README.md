# WhiskrImageSPM

A Swift Package Manager module for handling image operations in the Whiskr application. This package provides a comprehensive solution for image uploading, processing, and management within iOS applications.

## Overview

WhiskrImageSPM simplifies image handling with features for:
- Uploading images to a server
- Processing images from PhotosPicker
- Managing image metadata
- Deleting images
- Providing a consistent UI for image selection

## Requirements

- iOS 17.0+
- Swift 6.1+
- Xcode 15.0+

## Dependencies

- [Factory](https://github.com/hmlongco/Factory) (v2.4.5) - Dependency injection framework
- SQAUtility - Local utility package
- SQAServices - Local services package

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "path/to/WhiskrImageSPM.git", branch: "main")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["WhiskrImageSPM"]
)
```

## Architecture

The package follows a clean architecture approach with the following components:

### Models

- **ImageModel**: Represents image data including URLs, IDs, and the processed UIImage
- **ResponseModel**: Generic wrapper for API responses with data and error handling

### ViewModels

- **WhiskrImageViewModel**: Manages image operations including processing, uploading, and deletion

### Views

- **WhiskrImagePicker**: SwiftUI view for selecting and previewing images with a circular display and customizable appearance

### DataSource

- **ImageDataSourceProtocol**: Defines the interface for image operations
- **ImageDataSourceImplementation**: Implements the protocol with network operations

### Coordinators

- **WhiskrImageCoordinator**: Manages the navigation and workflow of image operations

## Usage

### Initialization

```swift
import WhiskrImageSPM

// Initialize the package
WhiskrImageSPM.start()
```

### Image Picker

```swift
import SwiftUI
import WhiskrImageSPM

struct ContentView: View {
    @StateObject private var viewModel = WhiskrImageViewModel()
    
    var body: some View {
        VStack {
            WhiskrImagePicker(
                selectedImage: viewModel.selectedImage,
                placeholderText: "Select profile image", 
                placeholderIcon: "photo.badge.plus",
                type: .userProfile,
                typeID: "user123",
                allowInternalUse: true
            )
            
            Button("Upload Image") {
                Task {
                    let response = await viewModel.uploadImage(folder: .userProfile)
                    // Handle response
                }
            }
        }
    }
}
```

The `WhiskrImagePicker` provides:
- Circular image display with placeholder
- Button to select an image from the photo library
- Button to remove the selected image
- Automatic upload capabilities
- Customizable styling

### Processing and Uploading Images

```swift
import WhiskrImageSPM
import PhotosUI

// In your view controller or view model
func handleImageSelection(from item: PhotosPickerItem) {
    let viewModel = WhiskrImageViewModel()
    
    Task {
        do {
            // Process the image
            let processedImage = try await viewModel.processImage(from: item)
            
            // Upload the image
            let response = await viewModel.uploadImage(folder: .userProfile)
            
            if response.isSuccess {
                // Handle successful upload
                print("Image uploaded successfully: \(response.data?.url ?? "")")
            } else {
                // Handle error
                print("Upload failed: \(response.error ?? "Unknown error")")
            }
        } catch {
            print("Error processing image: \(error.localizedDescription)")
        }
    }
}
```

### Deleting Images

```swift
func deleteUserProfileImage(imageId: String, userId: String) {
    let viewModel = WhiskrImageViewModel()
    
    Task {
        let response = await viewModel.deleteImage(
            imageID: imageId,
            type: .userProfile,
            typeID: userId
        )
        
        if response.isSuccess {
            print("Image deleted successfully")
        } else {
            print("Failed to delete image: \(response.error ?? "Unknown error")")
        }
    }
}
```

## Image Folder Types

The package supports different image categories:

```swift
public enum ImageFolderName: String {
    case userProfile = "user-profile-images"
    case recipeImage = "pet-recipe-images"
    case petProfile = "pet-profile-images"
    case lostAndFoundImage = "lost-and-found-images"
}
```

## Integration with Factory

WhiskrImageSPM uses the Factory dependency injection framework to manage dependencies:

```swift
// Register dependencies
extension WhiskrImageSPM {
    var imageDataSource: Factory<ImageDataSourceProtocol> {
        self { ImageDataSourceImplementation.shared }
            .singleton
    }
    
    var selectedImage: Factory<SharedImageState> {
        self { SharedImageState() }
            .singleton
    }
}

// Use dependencies
@Injected(\WhiskrImageSPM.imageDataSource) private var imageDataSource
@Injected(\WhiskrImageSPM.selectedImage) private var sharedImageState
```

## License

[Your License Information]

## Author

Danis Preldzic 