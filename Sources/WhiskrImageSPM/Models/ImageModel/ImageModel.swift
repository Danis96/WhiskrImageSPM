//
//  ImageModel.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

import Foundation
import SwiftUI

public struct ImageModel: Codable, Sendable {
    let id: String?
    let url: String?
    let thumbnail: String?
    let imageId: String?
    let imageProcessed: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case thumbnail = "thumbnailUrl"
        case imageId
    }
    
    public init(thumbnail: String = "", url: String = "", imageId: String = "", id: String = "", imageProcessed: UIImage? = nil) {
        self.thumbnail = thumbnail
        self.url = url
        self.imageId = imageId
        self.id = id
        self.imageProcessed = imageProcessed
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        imageId = try container.decodeIfPresent(String.self, forKey: .imageId)
        imageProcessed = nil // UIImage isn't part of the JSON, so we initialize it as nil
    }
    
    public func toJson() -> [String: String] {
        var json: [String: String] = [:]
        if let id = id { json["id"] = id }
        if let url = url { json["url"] = url }
        if let thumbnail = thumbnail { json["thumbnailUrl"] = thumbnail }
        if let imageId = imageId { json["imageId"] = imageId }
        return json
    }
}
