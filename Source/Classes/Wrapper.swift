import Foundation

public protocol LZCompatible: AnyObject {}

public protocol LZCompatibleValue {}

public struct LZWrapper<Base> {
    
    public let base: Base
    
    init(base: Base) {
        self.base = base
    }
}

extension LZCompatible {
    
    public var lz: LZWrapper<Self> {
        get { return LZWrapper(base: self) }
        set { }
    }
    
    public static var lz: LZWrapper<Self>.Type {
        get { return LZWrapper<Self>.self }
        set { }
    }
}

extension LZCompatibleValue {
    
    public var lz: LZWrapper<Self> {
        get { return LZWrapper(base: self) }
        set { }
    }
    
    public static var lz: LZWrapper<Self>.Type {
        get { return LZWrapper<Self>.self }
        set { }
    }
}
