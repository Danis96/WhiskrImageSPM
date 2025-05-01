//
//  ImageModel.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

import Foundation

public struct ImageModel: Codable, Sendable {
    let id: String?
    let url: String?
    let thumbnail: String?
    let imageId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case thumbnail = "thumbnailUrl"
        case imageId
    }
    
   public init(thumbnail: String = "", url: String = "", imageId: String = "", id: String = "") {
        self.thumbnail = thumbnail
        self.url = url
        self.imageId = imageId
        self.id = id
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
