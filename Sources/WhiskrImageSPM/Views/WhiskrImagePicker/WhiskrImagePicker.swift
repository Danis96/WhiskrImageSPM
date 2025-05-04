//
//  WhiskrImagePicker.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

import SwiftUI
import PhotosUI
import Factory


@MainActor
public struct WhiskrImagePicker: View {
    
    @EnvironmentObject private var viewModel: WhiskrImageViewModel
    @Binding private var selectedImage: ImageModel?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    private var placeholderText: String? = "Select an image"
    private var placeholderIcon: String
    private var type: ImageFolderName
    private var typeID: String
    private var allowInternalUse: Bool
    
    
    
    public init(selectedImage: Binding<ImageModel?>, placeholderText: String? = nil, placeholderIcon: String = "photo.badge.plus", type: ImageFolderName = .userProfile, typeID: String =  "userid||petid||recipeid", allowInternalUse: Bool = true) {
        self._selectedImage = selectedImage
        self.placeholderText = placeholderText
        self.placeholderIcon = placeholderIcon
        self.type = type
        self.typeID = typeID
        self.allowInternalUse = allowInternalUse
    }
    
    public var body: some View {
        ZStack {
            VStack {
                imageDisplayView
                
                if selectedImage != nil {
                    removeImageButton
                } else {
                    imagePickerButton
                }
            }
            .onChange(of: selectedItem, perform: handleImageSelection)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Failed to load image: \(errorMessage)")
            }
            
        }
        
    }
}

private extension WhiskrImagePicker {
    var imageDisplayView: some View {
        Group {
            if let selectedImage {
                if let imageUrl = selectedImage.url, let url = URL(string: imageUrl) {
                    // Remote image handling
                    AsyncImage(url: url) { phase in
                        handleImagePhase(phase)
                    }
                } else if !allowInternalUse, let processedImage = selectedImage.imageProcessed {
                    // Local processed image handling
                    Image(uiImage: processedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                } else {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
    }
    
    private func handleImagePhase(_ phase: AsyncImagePhase) -> some View {
        switch phase {
            case .empty:
                return AnyView(ProgressView())
            case .success(let image):
                return AnyView(
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                )
            case .failure:
                return AnyView(placeholderView)
            @unknown default:
                return AnyView(placeholderView)
        }
    }
    
    var imagePickerButton: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            HStack(spacing: 12) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 20, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient:  Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
    
    var removeImageButton: some View {
        Button(action: {
            if allowInternalUse {
                deleteImageSelection()
            } else {
                deleteLocalImageSelection()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "xmark.square.fill")
                    .font(.system(size: 20, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient:  Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
    
    var placeholderView: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: placeholderIcon)
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        if let placeholderText {
                            Text(placeholderText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        
                    }
                )
                .frame(width: 200, height: 200)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                )
        }
    }
}

// MARK: - Custom Modifiers
private extension WhiskrImagePicker {
    struct ShakeEffect: GeometryEffect {
        var amount: CGFloat = 10
        var shakesPerUnit = 3
        var animatableData: CGFloat
        
        func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(
                CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0)
            )
        }
    }
}

// MARK: - Image Selection Handler
private extension WhiskrImagePicker {
    func handleImageSelection(_ item: PhotosPickerItem?) {
        guard let item else { return }
        
        Task {
            do {
                if allowInternalUse {
                    try await loadAndSetImage(from: item)
                } else {
                    try await loadImage(from: item)
                }
            } catch {
                print("PhotoPicker Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadAndSetImage(from item: PhotosPickerItem) async throws {
        let image = try await viewModel.processAndUploadImage(from: item, folder: type)
        print("Load and set image: \(image.imageId ?? "")")
        selectedImage = image
    }
    
    private func loadImage(from item: PhotosPickerItem) async throws {
        let image = try await viewModel.processImage(from: item)
        print("Load and set image processed")
        selectedImage = image
    }
    
    private func deleteImageSelection() {
        let imageID = selectedImage?.imageId ?? ""
        print("imageID image: \(imageID)")
        withAnimation(.spring) {
            Task {
                do {
                    try await viewModel.deleteImage(imageID: imageID, type: type, typeID: typeID)
                } catch {
                    //
                }
            }
            deleteLocalImageSelection()
        }
    }
    
    private func deleteLocalImageSelection() {
        viewModel.selectedImage.wrappedValue = nil
        selectedImage?.imageProcessed = nil
        selectedImage = nil
        selectedItem = nil
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var previewImage: ImageModel?
        
        var body: some View {
            WhiskrImagePicker(selectedImage: $previewImage, placeholderText: "Add image profile photo")
                .padding()
            
        }
    }
    
    return PreviewWrapper()
}
