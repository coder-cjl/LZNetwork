//
//  Response.swift
//  LZNetwork
//
//  Created by 雷子 on 2024/5/22.
//

import Foundation

public struct LZResponse<T: Decodable>: Decodable {
    public let message: String?
    public let code: Int?
    public let data: T?

    public var isSuccess: Bool? {
        get {
            code == 0
        }
    }
}

