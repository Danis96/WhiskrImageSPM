//
//  APIPathHelper.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

public enum ImagesRoute: String, Identifiable {
    case uploadImage
    case delete
    
    public var id: String { rawValue }
}

public final class APIPaths: @unchecked Sendable {
    public static let shared = APIPaths()
    private init() {}
    
    public func path(for endpoint: ImagesRoute, String concatValue: String? = nil,  String secondConcatValue: String? = nil, String thirdConcatValue: String? = nil) -> String {
        switch endpoint {
            case .uploadImage:
                return "/image"
            case .delete:
                return "image/\(concatValue ?? "")/\(secondConcatValue ?? "")/image/\(thirdConcatValue ?? "")"
        }
    }
}
