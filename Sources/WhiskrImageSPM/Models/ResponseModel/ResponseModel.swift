//
//  ResponseModel.swift
//  WhiskrImageSPM
//
//  Created by Danis Preldzic on 1. 5. 2025..
//

public struct ResponseModel<T>: Codable, Sendable where T: Codable, T: Sendable {
    var data: T?
    var error: String?
    
    init(data: T?, error: String?) {
        self.data = data
        self.error = error
    }
    
    var isSuccess: Bool {
        return data != nil && error == nil
    }
}
