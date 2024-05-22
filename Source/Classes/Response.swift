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

