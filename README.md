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

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/WhiskrImageSPM.git", branch: "main")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["WhiskrImageSPM"]
)
```

### Manual Integration

If you prefer to include the package directly:

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/WhiskrImageSPM.git
   ```

2. Drag the WhiskrImageSPM folder into your Xcode project
3. Ensure you also include the required dependencies

## Dependencies

- [Factory](https://github.com/hmlongco/Factory) (v2.4.5) - Dependency injection framework
- SQAUtility - Local utility package
- SQAServices - Local services package

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
    @StateObject private var viewModel: WhiskrImageViewModel = WhiskrImageViewModel()
    
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

### Processing and Uploading Images

```swift
import WhiskrImageSPM
import PhotosUI

// In your view controller or view model
func handleImageSelection(from item: PhotosPickerItem) {
    let viewModel: WhiskrImageViewModel = WhiskrImageViewModel()
    
    Task {
        do {
            // Process the image
            let processedImage: ImageModel = try await viewModel.processImage(from: item)
            
            // Upload the image
            let response: ResponseModel<ImageModel> = await viewModel.uploadImage(folder: .userProfile)
            
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
    let viewModel: WhiskrImageViewModel = WhiskrImageViewModel()
    
    Task {
        let response: ResponseModel<String> = await viewModel.deleteImage(
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

## Contributing

We welcome contributions to the WhiskrImageSPM project! Here's how you can help:

### Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Coding Standards

- Follow Swift API Design Guidelines
- Write comprehensive unit tests for new features
- Keep the code modular and maintainable
- Document public APIs with appropriate comments

### Pull Request Process

1. Ensure your code passes all tests
2. Update documentation if needed
3. Get approval from at least one code owner
4. Your PR will be merged once approved

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Danis Preldzic  
Email: danis.preldzic@gmail.com  
LinkedIn: [Danis Preldzic](https://www.linkedin.com/in/danis-preldzic-3449b1169/)  
GitHub: [@yourusername](https://github.com/Danis96)

## Acknowledgments

- [Factory](https://github.com/hmlongco/Factory) for dependency injection
- The SwiftUI team for the excellent framework