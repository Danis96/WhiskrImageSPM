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
    
    // MARK: - Navigation
    @Published public var sheet: ImagesRoute?
    
    private init() {
        self.imageViewModel = WhiskrImageViewModel()
    }
    
    // MARK: - CoordinatorProtocol Methods
    public func start() -> AnyView {
        print("Starting Whiskr Image Coordinator")
        return AnyView(
            Text("")
            // here will be view
//            AuthenticationRootView()
//                .environmentObject(authViewModel)
//                .environmentObject(self)
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
