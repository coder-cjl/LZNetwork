//
//  TargetType.swift
//  LZNetwork
//
//  Created by 雷子 on 2024/5/22.
//

import Foundation
import Moya
import Alamofire

public protocol LZTargetType: TargetType { }

public typealias RequestResultHandler<T: Decodable> = (LZResult<T>) -> Void
public typealias RequestSuccessResultHandle<T: Decodable> = (T?) -> Void


extension LZTargetType {
    
    public func request<T: Decodable>(
        type: T.Type? = nil,
        plugins: [PluginType] = [LZGetwayPlugin()]
    ) async -> LZResult<T> {
        return await baseRequest(type: type, plugins: plugins)
    }
    
    public func request<T: Decodable>(
        type: T.Type? = nil,
        plugins: [PluginType] = [LZGetwayPlugin()],
        handle: @escaping RequestResultHandler<T>
    ) -> Void {
        _Concurrency.Task {
            let result = await baseRequest(type: type, plugins: plugins)
            switch result {
            case .success(let value):
                handle(.success(value))
            case .failure(let error):
                handle(.failure(error))
            }
        }
    }
    
    private func baseRequest<T: Decodable>(
        type: T.Type? = nil,
        plugins: [PluginType] = [LZGetwayPlugin()]
    ) async -> LZResult<T> {
        return await withCheckedContinuation { con in
            let provider = MoyaProvider<Self>()
            provider.request(self) { result in
                switch result {
                case .success(let response):
                    handleSuccess(data: response.data, continuation: con)
                case .failure(let moyaError):
                    handleFailure(error: moyaError, continuation: con)
                }
            }
        }
    }
    
    private func handleSuccess<T: Decodable>(
        data: Data,
        continuation: CheckedContinuation<LZResult<T>, Never>
    ) -> Void {
        do {
            let result = try JSONDecoder().decode(LZResponse<T>.self, from: data)
            continuation.resume(returning: .success(result.data))
        } catch {
            continuation.resume(returning: .failure(.default("Model格式不对", -1)))
        }
    }
    
    private func handleFailure<T: Decodable>(
        error: any Error,
        continuation: CheckedContinuation<LZResult<T>, Never>
    ) -> Void {
        if let moyaError = error as? MoyaError,
           case .underlying(let underlyingError, _) = moyaError,
           let afError = underlyingError as? Alamofire.AFError {
            handleAFError(afError: afError, continuation: continuation)
        } else {
            continuation.resume(returning: .failure(.systemError(error)))
        }
    }
    
    private func handleAFError<T: Decodable>(
        afError: Alamofire.AFError,
        continuation: CheckedContinuation<LZResult<T>, Never>
    ) -> Void {
        switch afError {
        case .requestAdaptationFailed(let requestError):
            if let afRequestError = requestError as? Alamofire.AFError,
               case .urlRequestValidationFailed(let reason) = afRequestError,
               case .bodyDataInGETRequest(let data) = reason {
                handleSuccess(data: data, continuation: continuation)
            } else {
                continuation.resume(returning: .failure(.systemError(requestError)))
            }
        default:
            continuation.resume(returning: .failure(.afError(afError)))
        }
    }
}
