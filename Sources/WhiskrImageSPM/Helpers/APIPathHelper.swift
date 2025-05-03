//
//  APIPathHelper.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

public enum ImagesRoute: String, Identifiable {
    case uploadImage
    case deleteImage
    
    public var id: String { rawValue }
}

public final class ImageAPIPaths: @unchecked Sendable {
    public static let shared: ImageAPIPaths = ImageAPIPaths()
    private init() {}
    
    public func path(for endpoint: ImagesRoute, concatValue: String? = nil,  secondConcatValue: String? = nil,  thirdConcatValue: String? = nil) -> String {
        switch endpoint {
            case .uploadImage:
                return "/image"
            case .deleteImage:
                return "/image/\(concatValue ?? "")/\(secondConcatValue ?? "")/image/\(thirdConcatValue ?? "")"
        }
    }
}
