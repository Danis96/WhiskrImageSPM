//
//  ImageDataSourceProtocol.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

import Foundation
import UIKit

public protocol ImageDataSourceProtocol: Sendable {
    func uploadImage(image: UIImage, folder: String, fileName: String) async throws -> ResponseModel<ImageModel>
    func deleteImage(imageId: String, type: String, typeId: String) async throws -> ResponseModel<String>
}

