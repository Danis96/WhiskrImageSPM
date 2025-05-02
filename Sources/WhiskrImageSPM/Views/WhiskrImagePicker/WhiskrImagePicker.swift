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
    
    
    
    public init(selectedImage: Binding<ImageModel?>, placeholderText: String? = nil, placeholderIcon: String = "photo.badge.plus") {
        self._selectedImage = selectedImage
        self.placeholderText = placeholderText
        self.placeholderIcon = placeholderIcon
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
            if let selectedImage, let imageUrl = selectedImage.url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        case .failure(_):
                            placeholderView
                        @unknown default:
                            placeholderView
                    }
                }
            } else {
                placeholderView
            }
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
            withAnimation(.spring) {
                selectedImage = nil
                selectedItem = nil
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
        
        print("PhotoPicker: Item selected")
        Task {
            do {
                try await loadAndSetImage(from: item)
                print("PhotoPicker: Successfully loaded image")
            } catch {
                print("PhotoPicker Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadAndSetImage(from item: PhotosPickerItem) async throws {
        selectedImage = try await viewModel.processAndUploadImage(from: item, folder: .user)
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
