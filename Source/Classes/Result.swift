//
//  Result.swift
//  LZNetwork
//
//  Created by 雷子 on 2024/5/22.
//

import Foundation
import Moya

enum LZResult<T> {
    case success(T?)
    case failure(LZError)
}
