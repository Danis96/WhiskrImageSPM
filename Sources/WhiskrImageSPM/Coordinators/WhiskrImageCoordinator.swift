//
//  WhiskrImageCoordinator.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

import SwiftUI
import Factory
import SQAUtility

@MainActor
public final class WhiskrImageCoordinator: CoordinatorProtocol {
    
    
    public static let shared = WhiskrImageCoordinator()
    
    // MARK: - Protocol Requirements
    public typealias Route = ImagesRoute
    @Published public var path = NavigationPath()
    
    // MARK: - View Models
    @Published public private(set) var imageViewModel: WhiskrImageViewModel
    
    @Injected(\WhiskrImageSPM.selectedImage) public var sharedImageState
    
    // MARK: - Navigation
    @Published public var sheet: ImagesRoute?
    
    private init() {
        self.imageViewModel = WhiskrImageViewModel()
    }
    
    // MARK: - CoordinatorProtocol Methods
    public func start() -> AnyView {
        print("Starting Whiskr Image Coordinator")
        return AnyView(
            WhiskrImagePicker(selectedImage: imageViewModel.selectedImage,
                              placeholderText: "Select an image")
            .environmentObject(imageViewModel)
            .environmentObject(self)
        )
    }
    
    // Pass a custom binding and placeholder text
    public func start(selectedImage: Binding<ImageModel?>, placeholderText: String? = nil, placeHolderIcon: String? = nil, type: ImageFolderName = .userProfile, typeID: String = "userid||petid||recipeid", allowInternalUse: Bool = true) -> AnyView {
        print("Starting Whiskr Image Coordinator with custom binding")
        // Update the shared state with the external binding and create a two-way binding
        self.sharedImageState.image = selectedImage.wrappedValue
        
        // Create a new binding that updates both the shared state and the passed binding
        let combinedBinding = Binding<ImageModel?>(
            get: { selectedImage.wrappedValue },
            set: { newValue in
                self.sharedImageState.image = newValue
                selectedImage.wrappedValue = newValue
            }
        )
        
        return AnyView(
            WhiskrImagePicker(selectedImage: combinedBinding,
                              placeholderText: placeholderText,
                              placeholderIcon: placeHolderIcon ?? "photo.badge.plus",
                              type: type,
                              typeID: typeID,
                              allowInternalUse: allowInternalUse
                             )
            .environmentObject(imageViewModel)
            .environmentObject(self)
        )
    }
    
    public func navigate(to route: ImagesRoute) {
        path.append(route)
    }
    
    public func pop() {
        path.removeLast()
    }
    
    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    public func present(_ route: ImagesRoute) {
        sheet = route
    }
    
    public func dismissSheet() {
        sheet = nil
    }
}
