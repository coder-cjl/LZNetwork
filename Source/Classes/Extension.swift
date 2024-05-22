import Foundation

extension Data: LZCompatibleValue { }

extension [String: Any]: LZCompatibleValue { }

extension String: LZCompatibleValue { }

extension LZWrapper where Base == Data {
    
    func asString() -> String {
        String(decoding: base, as: UTF8.self)
    }

    func asJSONObject() throws -> Any {
        try JSONSerialization.jsonObject(with: base, options: .allowFragments)
    }
}

extension LZWrapper where Base == [String: Any] {
    
    func asString() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: base, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}


extension LZWrapper where Base == String {
    
    func asJSONObject() -> [String: Any]? {
        if let jsonData = base.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            return jsonObject
        }
        return nil
    }
}
