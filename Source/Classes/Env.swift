//
//  Env.swift
//  LZNetwork
//
//  Created by 雷子 on 2024/5/22.
//

import Foundation
import Alamofire

public enum LZEnvEnum: String {
    case dev
    case test
    case uat
    case prod
}

public class LZEnv {
    
    public static let `default` = LZEnv()
    
    /// 当前环境
    public var currentEnv: LZEnvEnum?
    
    /// 当前URLConfig
    public var currentURLConfig: [String: Any]?
    
    /// 全局的URLConfig
    public var globalURLConfig: [String: Any]?
    
    /// 设置全局URLConfig
    public func setGlobalURLConfig(value: [String: Any]?) {
        globalURLConfig = value
        
        if let envStr = globalURLConfig?["env"] as? String, let env = LZEnvEnum(rawValue: envStr) {
            currentEnv = env
            changeCurrentEnv(env: env)
        }
    }
    
    /// 切换当前环境
    public func changeCurrentEnv(env: LZEnvEnum) {
        if let value = globalURLConfig?[env.rawValue] as? [String: Any] {
            currentURLConfig = value
        }
    }
    
    public func loadConfig( _ url: String, loadCache: Bool = false) -> Void {
        /// 如果有缓存策略
        if loadCache,
           let cacheString = UserDefaults.standard.string(forKey: url),
           let cachedJSON = cacheString.lz.asJSONObject() {
            setGlobalURLConfig(value: cachedJSON)
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        AF.request(url).response(queue: .global(qos: .userInteractive), completionHandler: { response in
            if let data = response.data, let value = try? data.lz.asJSONObject() as? [String: Any] {
                LZEnv.default.setGlobalURLConfig(value: value)
                if (loadCache) {
                    if let valueString = value.lz.asString() {
                        UserDefaults.standard.set(valueString, forKey: url)
                    }
                }
            }
            semaphore.signal()
        }).resume()
        
        semaphore.wait()
    }
    
}
