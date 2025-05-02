// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Factory

final public class WhiskrImageSPM: SharedContainer {
    public let manager = ContainerManager()
    public static let shared = WhiskrImageSPM()
}

public extension WhiskrImageSPM {
    var imageDataSource: Factory<ImageDataSourceProtocol> {
        self { ImageDataSourceImplementation.shared }
            .singleton
    }
    
    @MainActor
    static func start() -> some View {
        WhiskrImageCoordinator.shared.start()
    }
    
    var selectedImage: Factory<SharedImageState> {
        self { SharedImageState() }
            .singleton
    }
    
}

public class SharedImageState: ObservableObject {
    @Published public var image: ImageModel?
    
    public init(image: ImageModel? = nil) {
        self.image = image
    }
}


