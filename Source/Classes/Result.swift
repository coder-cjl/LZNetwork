import Foundation
import Moya

enum LZResult<T> {
    case success(T?)
    case failure(LZError)
}
