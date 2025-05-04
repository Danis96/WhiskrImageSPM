//
//  ResponseModel.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

public struct ResponseModel<T>: Codable, Sendable where T: Codable, T: Sendable {
    public var data: T?
    public var error: String?
    
    public init(data: T?, error: String?) {
        self.data = data
        self.error = error
    }
    
    public var isSuccess: Bool {
        return data != nil && error == nil
    }
}
