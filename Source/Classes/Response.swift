//
//  Response.swift
//  LZNetwork
//
//  Created by 雷子 on 2024/5/22.
//

import Foundation

struct LZResponse<T: Decodable>: Decodable {
    let message: String?
    let code: Int?
    let data: T?

    var isSuccess: Bool? {
        get {
            code == 0
        }
    }
}

