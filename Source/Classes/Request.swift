//
//  Request.swift
//  LZNetwork
//
//  Created by 雷子 on 2024/5/22.
//

import Foundation
import Moya
import _Concurrency
import Alamofire

public class LZRequest<T: Decodable> {
    
    typealias RequestResultHandler = (LZResult<T>) -> Void
    typealias RequestSuccessResultHandler = (T?) -> Void
    
    var plugins: [PluginType]?
    
    init(plugins: [PluginType] = [LZGetwayPlugin()]) {
        self.plugins = plugins
    }
    
    public func request<P: LZTargetType>(
        _ target: P,
        type: T.Type
    ) async -> LZResult<T> {
        return await withCheckedContinuation { con in
            let provider = MoyaProvider<P>(plugins: self.plugins!)
            provider.request(target) { [weak self] result in
                switch result {
                case .success(let response):
                    self?.handleSuccess(data: response.data, continuation: con)
                case .failure(let moyaError):
                    self?.handleFailure(error: moyaError, continuation: con)
                }
            }
        }
    }
    
    private func handleSuccess(
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
    
    private func handleFailure(
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
    
    private func handleAFError(
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
    
    func request<P: LZTargetType>(_ target: P) async -> LZResult<T> {
        return await request(target, type: T.self)
    }
    
    func request<P: LZTargetType>(
        target: P,
        type: T.Type,
        handle: @escaping RequestResultHandler
    ) -> Void {
        _Concurrency.Task {
            let result = await request(target, type: type)
            switch result {
            case .success(let value):
                handle(.success(value))
            case .failure(let error):
                handle(.failure(error))
            }
        }
    }
    
    func request<P: LZTargetType>(
        _ target: P,
        handle: @escaping RequestResultHandler
    ) -> Void {
        _Concurrency.Task {
            let result = await request(target, type: T.self)
            switch result {
            case .success(let value):
                handle(.success(value))
            case .failure(let error):
                handle(.failure(error))
            }
        }
    }
    
   func requestOnlySuccess<P: LZTargetType>(
        _ target: P,
        type: T.Type
    ) async -> T? {
        let result = await request(target, type: type)
        switch result {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }
    
    func requestOnlySuccess<P: LZTargetType>(_ target: P) async -> T? {
        let result = await request(target, type: T.self)
        switch result {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }
    
  func requestOnlySuccess<P: LZTargetType>(
        _ target: P,
        type: T.Type,
        handle: @escaping RequestSuccessResultHandler
    ) -> Void {
        _Concurrency.Task {
            let result = await request(target, type: type)
            switch result {
            case .success(let value):
                handle(value)
            case .failure(_):
                handle(nil)
            }
        }
    }
    
   func requestOnlySuccess<P: LZTargetType>(
        _ target: P,
        handle: @escaping RequestSuccessResultHandler
    ) -> Void {
        _Concurrency.Task {
            let result = await request(target, type: T.self)
            switch result {
            case .success(let value):
                handle(value)
            case .failure(_):
                handle(nil)
            }
        }
    }
}
