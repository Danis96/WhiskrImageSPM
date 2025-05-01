//
//  ImageDataSourceImplementation.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

import Foundation
import SQAServices
import SQAUtility
import UIKit
import Factory

public final class ImageDataSourceImplementation: ImageDataSourceProtocol, @unchecked Sendable {
    
    public static let shared = ImageDataSourceImplementation()
    
    private init() {}
    
    @Injected(\SQAServices.networkManager) var networkService: NetworkServiceManager
    @Injected(\SQAServices.apiHeaderHelper) var headerHelper: ApiHeaders
    @Injected(\SQAUtility.storageManager) var storageManager: StorageManager
    
    public func uploadImage(image: UIImage, folder: String, fileName: String) async throws -> ResponseModel<ImageModel> {
        do {
            let response = try await networkService.uploadImage(
                path: APIPaths.shared.path(for: .uploadImage),
                image: image,
                folder: folder,
                fileName: fileName,
                headers: headerHelper.getValue(type: .multipart_form_data, accessToken: getAuthToken() ?? ""),
                as: ImageModel.self,
            )
            return ResponseModel(data: response, error: nil)
        } catch {
            return ResponseModel(data: nil, error: error.localizedDescription)
        }
    }
    
    private func getAuthToken() -> String? {
        do {
            let token = try storageManager.getSecureValue(forKey: .accessToken)
            return token
        } catch {
            return nil
        }
    }
    
}
