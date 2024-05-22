//
//  Error.swift
//  LZNetwork
//
//  Created by 雷子 on 2024/5/22.
//

import Foundation
import Moya
import Alamofire

public enum LZError: Error {
    case `default`(String, Int)
    case systemError(Error)
    case moyaError(MoyaError)
    case afError(AFError)
}

extension LZError: CustomNSError {
    
    public static let domain = "com.www.lz.ios.Error"
    public static var errorDomain: String { domain }
    
    public var errorCode: Int {
        switch self {
        case .default(_, let code):
            return code
        case .systemError(_):
            return -1
        case .moyaError(let moyaError):
            return moyaError.errorCode
        case .afError(let afError):
            return afError.responseCode ?? -1
        }
    }
}

extension LZError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .default(let message, _):
            return message
        case .systemError(let error):
            return error.localizedDescription
        case .moyaError(let error):
            return error.errorDescription
        case .afError(let error):
            return error.errorDescription
        }
    }
}
