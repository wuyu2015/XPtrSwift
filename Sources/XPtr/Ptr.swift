extension XPtr {
    public struct Ptr: MutableCollection, RandomAccessCollection, RangeReplaceableCollection {
        
        public let p: UnsafeMutablePointer<UInt8>
        public let count: Int
        let k: SecretKey
        let countType: CountType
        
        let offset8: Int
        let offset64: Int
        
        let alignment1k: Int
        let alignment64: Int
        
        // Collection 协议要求实现的
        public var startIndex: Int { 0 }
        public var endIndex: Int { count }
        
        public init() {
            fatalError()
        }
        
        public init(bytes: UnsafeMutablePointer<UInt8>, count: Int, key: SecretKey) {
            p = bytes
            self.count = count
            countType = CountType(count: count)
            k = key
            
            switch countType {
            case .x8:
                offset8 = SecretKey.offset8(count: count)
                offset64 = 0
                alignment64 = 0
                alignment1k = 0
            case .x64:
                offset8 = 0
                offset64 = SecretKey.offset64(count: count)
                alignment64 = 0
                alignment1k = 0
            case .x64X8:
                offset8 = SecretKey.offset8(count: count)
                offset64 = SecretKey.offset64(count: count)
                alignment64 = SecretKey.alignment64(count: count)
                alignment1k = 0
            case .x1kX8:
                offset8 = SecretKey.offset8(count: count)
                offset64 = 0
                alignment64 = 0
                alignment1k = 1024
            case .x1kX64:
                offset8 = 0
                offset64 = SecretKey.offset64(count: count)
                alignment64 = SecretKey.alignment64(count: count)
                alignment1k = 1024
            case .x1kX64X8:
                offset8 = SecretKey.offset8(count: count)
                offset64 = SecretKey.offset64(count: count)
                alignment64 = SecretKey.alignment64(count: count)
                alignment1k = 1024
            case .x1kPlusX8:
                offset8 = SecretKey.offset8(count: count)
                offset64 = 0
                alignment64 = 0
                alignment1k = SecretKey.alignment1k(count: count)
            case .x1kPlusX64:
                offset8 = 0
                offset64 = SecretKey.offset64(count: count)
                alignment64 = 0
                alignment1k = SecretKey.alignment1k(count: count)
            case .x1kPlusX64X8:
                offset8 = SecretKey.offset8(count: count)
                offset64 = SecretKey.offset64(count: count)
                alignment64 = SecretKey.alignment64(count: count)
                alignment1k = SecretKey.alignment1k(count: count)
            default: // .x1k, x1kPlus
                offset8 = 0
                offset64 = 0
                alignment64 = 0
                alignment1k = 0
            }
        }
        
        public subscript(index: Int) -> UInt8 {
            get {
                switch countType {
                case .x8:
                    let i8 = offset8 + index
                    return p[Int(k.X8[i8])] ^ k.H8[i8]
                case .x64:
                    let i64 = offset64 + index
                    return p[Int(k.X64[i64])] ^ k.H64[i64]
                case .x64X8:
                    if index < alignment64 {
                        let i64 = offset64 + index
                        return p[Int(k.X64[i64])] ^ k.H64[i64]
                    } else {
                        let i8 = offset8 + (index & 63)
                        return p[alignment64 + Int(k.X8[i8])] ^ k.H8[i8]
                    }
                case .x1k:
                    return p[Int(k.X1K[index])] ^ k.H1K[index]
                case .x1kX8:
                    if index < 1024 {
                        return p[Int(k.X1K[index])] ^ k.H1K[index]
                    } else {
                        let i8 = offset8 + (index & 63)
                        return p[1024 + Int(k.X8[i8])] ^ k.H8[i8]
                    }
                case .x1kX64:
                    if index < 1024 {
                        return p[Int(k.X1K[index])] ^ k.H1K[index]
                    } else {
                        let i64 = offset64 + (index & 1023)
                        return p[1024 + Int(k.X64[i64])] ^ k.H64[i64]
                    }
                case .x1kX64X8:
                    if index < 1024 {
                        return p[Int(k.X1K[index])] ^ k.H1K[index]
                    } else if index < alignment64 {
                        let i64 = offset64 + (index & 1023)
                        return p[1024 + Int(k.X64[i64])] ^ k.H64[i64]
                    } else {
                        let i8 = offset8 + (index & 63)
                        return p[alignment64 + Int(k.X8[i8])] ^ k.H8[i8]
                    }
                case .x1kPlus:
                    let i = index & 1023
                    return p[index & 0x7FFFFFFFFFFFFC00 + Int(k.X1K[i])] ^ k.H1K[i]
                case .x1kPlusX8:
                    if index < alignment1k {
                        let i = index & 1023
                        return p[index & 0x7FFFFFFFFFFFFC00 + Int(k.X1K[i])] ^ k.H1K[i]
                    } else {
                        let i8 = offset8 + (index & 63)
                        return p[alignment1k + Int(k.X8[i8])] ^ k.H8[i8]
                    }
                case .x1kPlusX64:
                    if index < alignment1k {
                        let i = index & 1023
                        return p[index & 0x7FFFFFFFFFFFFC00 + Int(k.X1K[i])] ^ k.H1K[i]
                    } else {
                        let i64 = offset64 + (index & 1023)
                        return p[alignment1k + Int(k.X64[i64])] ^ k.H64[i64]
                    }
                case .x1kPlusX64X8:
                    if index < alignment1k {
                        let i = index & 1023
                        return p[index & 0x7FFFFFFFFFFFFC00 + Int(k.X1K[i])] ^ k.H1K[i]
                    } else if index < alignment64 {
                        let i64 = offset64 + (index & 1023)
                        return p[alignment1k + Int(k.X64[i64])] ^ k.H64[i64]
                    } else {
                        let i8 = offset8 + (index & 63)
                        return p[alignment64 + Int(k.X8[i8])] ^ k.H8[i8]
                    }
                }
            }
            set {
                switch countType {
                case .x8:
                    let i8 = offset8 + index
                    p[Int(k.X8[i8])] = newValue ^ k.H8[i8]
                case .x64:
                    let i64 = offset64 + index
                    p[Int(k.X64[i64])] = newValue ^ k.H64[i64]
                case .x64X8:
                    let i64 = offset64 + index
                    if index < alignment64 {
                        p[Int(k.X64[i64])] = newValue ^ k.H64[i64]
                    } else {
                        let i8 = offset8 + (index & 63)
                        p[alignment64 + Int(k.X8[i8])] = newValue ^ k.H8[i8]
                    }
                case .x1k:
                    p[Int(k.X1K[index])] = newValue ^ k.H1K[index]
                case .x1kX8:
                    if index < 1024 {
                        p[Int(k.X1K[index])] = newValue ^ k.H1K[index]
                    } else {
                        let i8 = offset8 + (index & 63)
                        p[1024 + Int(k.X8[i8])] = newValue ^ k.H8[i8]
                    }
                case .x1kX64:
                    if index < 1024 {
                        p[Int(k.X1K[index])] = newValue ^ k.H1K[index]
                    } else {
                        let i64 = offset64 + (index & 1023)
                        p[1024 + Int(k.X64[i64])] = newValue ^ k.H64[i64]
                    }
                case .x1kX64X8:
                    if index < 1024 {
                        p[Int(k.X1K[index])] = newValue ^ k.H1K[index]
                    } else if index < alignment64 {
                        let i64 = offset64 + (index & 1023)
                        p[1024 + Int(k.X64[i64])] = newValue ^ k.H64[i64]
                    } else {
                        let i8 = offset8 + (index & 63)
                        p[alignment64 + Int(k.X8[i8])] = newValue ^ k.H8[i8]
                    }
                case .x1kPlus:
                    let i = index & 1023
                    p[index & 0x7FFFFFFFFFFFFC00 + Int(k.X1K[i])] = newValue ^ k.H1K[i]
                case .x1kPlusX8:
                    let i = index & 1023
                    if index < alignment1k {
                        p[index & 0x7FFFFFFFFFFFFC00 + Int(k.X1K[i])] = newValue ^ k.H1K[i]
                    } else {
                        let i8 = offset8 + (index & 63)
                        p[alignment1k + Int(k.X8[i8])] = newValue ^ k.H8[i8]
                    }
                case .x1kPlusX64:
                    let i = index & 1023
                    if index < alignment1k {
                        p[index & 0x7FFFFFFFFFFFFC00 + Int(k.X1K[i])] = newValue ^ k.H1K[i]
                    } else {
                        let i64 = offset64 + (index & 1023)
                        p[alignment1k + Int(k.X64[i64])] = newValue ^ k.H64[i64]
                    }
                case .x1kPlusX64X8:
                    if index < alignment1k {
                        let i = index & 1023
                        p[index & 0x7FFFFFFFFFFFFC00 + Int(k.X1K[i])] = newValue ^ k.H1K[i]
                    } else if index < alignment64 {
                        let i64 = offset64 + (index & 1023)
                        p[alignment1k + Int(k.X64[i64])] = newValue ^ k.H64[i64]
                    } else {
                        let i8 = offset8 + (index & 63)
                        p[alignment64 + Int(k.X8[i8])] = newValue ^ k.H8[i8]
                    }
                }
            }
        }
    }
}
