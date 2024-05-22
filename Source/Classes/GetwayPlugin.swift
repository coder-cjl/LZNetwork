import Foundation
import Moya

open class LZGetwayPlugin: PluginType {
    
    /// 判断网关
    public func process(
        _ result: Result<Response, MoyaError>,
        target: any TargetType
    ) -> Result<Response, MoyaError> {
        switch result {
        case .success(let response):
            if response.statusCode == 200 {
                return .success(response)
            }
        case .failure(let error):
            return .failure(error)
        }
        return result
    }
}
