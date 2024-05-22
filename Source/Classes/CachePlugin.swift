//
//  CachePugin.swift
//  LZNetwork
//
//  Created by 雷子 on 2024/5/22.
//

import Foundation
import Moya
import Alamofire

open class LZCachePlugin: PluginType {
    
    public func prepare(
        _ request: URLRequest,
        target: any TargetType
    ) -> URLRequest {
        if let cacheData = LZCache.default.urlCache!.cachedResponse(for: request) {
            return applyCacheResponse(request, cachedResponse: cacheData)
        }
        return request
    }
    
    public func process(
        _ result: Result<Response, MoyaError>,
        target: any TargetType
    ) -> Result<Response, MoyaError> {
        switch result {
        case .success(let response):
            if let httpResponse = response.response {
                let cacheResponse = CachedURLResponse(response: httpResponse, data: response.data)
                LZCache.default.urlCache!.storeCachedResponse(cacheResponse, for: response.request!)
            }
        case .failure(_):
            break
        }
        return result
    }
    
    public func applyCacheResponse(
        _ request: URLRequest,
        cachedResponse: CachedURLResponse
    ) -> URLRequest {
        var newRequest = request
        newRequest.httpBody = cachedResponse.data
        return newRequest
    }
}
