extension XPtr {
    public struct SecretKey {
        static let count8 = 2016
        static let count64 = 7680
        
        // 2080 = 1 + 2 + 3 + ... + 64
        let X8: [UInt8]
        let H8: [UInt8]
        
        // 7680 = 64 + 128 + 192 + 256 + 320 + 384 + 448 + 512 + 576 + 640 + 704 + 768 + 832 + 896 + 960
        let X64: [UInt16]
        let H64: [UInt8]
        
        // 1024
        let X1K: [UInt16]
        let H1K: [UInt8]
        
        // MARK: Random
        public static func random() -> Self {
            return Self.init(X8: randomX8(), H8: randomH8(), X64: randomX64(), H64: randomH64(), X1K: randomX1K(), H1K: randomH1K())
        }
        
        @inline(__always)
        static func randomX8() -> [UInt8] {
            var result: [UInt8] = Array(repeating: 0, count: count8)
            result[1] = 1 // 固定前 3 位是 [0, 1, 0]
            
            var index = 3 // 从第 3 位开始
            for len in 3...63 {
                result.replaceSubrange(index..<index + len, with: Array<UInt8>(0..<UInt8(len)).shuffled()) // 生成金字塔数组
                index += len
            }
            return result
        }
        
        @inline(__always)
        static func randomX64() -> [UInt16] {
            var result: [UInt16] = Array(repeating: 0, count: count64)
            
            var index = 0
            for len in stride(from: 64, through: 960, by: 64) {
                result.replaceSubrange(index..<index + len, with: Array<UInt16>(0..<UInt16(len)).shuffled()) // 生成金字塔数组
                index += len
            }
            return result
        }
        
        @inline(__always)
        static func randomX1K() -> [UInt16] {
            return Array(0..<1024).shuffled()
        }
        
        @inline(__always)
        private static func randomH(count: Int) -> [UInt8] {
            return Array(repeating: 0, count: count).map { _ in
                UInt8.random(in: 1..<UInt8.max) // 不包含 0
            }
        }
        
        @inline(__always)
        static func randomH8() -> [UInt8] {
            return randomH(count: count8)
        }
        
        @inline(__always)
        static func randomH64() -> [UInt8] {
            return randomH(count: count64)
        }
        
        @inline(__always)
        static func randomH1K() -> [UInt8] {
            return randomH(count: 1024)
        }
        
        // MARK: Format
        private func formatArray<T: BinaryInteger>(_ arr: [T], from: Int, through: Int, by: Int, comment: Bool) -> String {
            var result: [String] = []
            var index = 0
            for capacity in stride(from: from, through: through, by: by) { // 每行 item 数
                result.append(Array(arr[index..<index + capacity]).map(String.init).joined(separator: ", ") + (comment ? ", // \(capacity)" : ","))
                index += capacity
            }
            return result.joined(separator: "\n")
        }
        
        func formatX8(comment: Bool = true) -> String {
            return formatArray(X8, from: 1, through: 63, by: 1, comment: comment)
        }
        
        func formatH8(comment: Bool = true) -> String {
            return formatArray(H8, from: 1, through: 63, by: 1, comment: comment)
        }
        
        func formatX64(comment: Bool = true) -> String {
            return formatArray(X64, from: 64, through: 960, by: 64, comment: comment)
        }
        
        func formatH64(comment: Bool = true) -> String {
            return formatArray(H64, from: 64, through: 960, by: 64, comment: comment)
        }
        
        func formatX1K() -> String {
            return X1K.map(String.init).joined(separator: ", ")
        }
        
        func formatH1K() -> String {
            return H1K.map(String.init).joined(separator: ", ")
        }
        
        func dump() -> String {
            return """
                X8: [
                \(formatX8())
                ],
                H8: [
                \(formatH8())
                ],
                X64: [
                \(formatX64())
                ],
                H64: [
                \(formatH64())
                ],
                X1K: [\(formatX1K())],
                H1K: [\(formatH1K())]
                """
        }
        
        // MARK: Offset
        
        // (1...n).sum()
        @inline(__always)
        static func sumTo(_ n: Int) -> Int {
            return (n * (n + 1)) >> 1 // n * (n + 1) / 2
        }
        
        @inline(__always)
        static func offset8(count: Int) -> Int {
            return sumTo((count & 63) - 1) // (count % 64) - 1
        }
        
        @inline(__always)
        static func offset64(count: Int) -> Int {
            let m1k = count & 1023
            guard m1k >= 64 else {
                return 0
            }
            let i64 = m1k & ~63 // m1k - m1k % 64
            let n = i64 >> 6 // i64 / 64
            return n * (n - 1) << 5 // n * (n - 1) / 2 * 64
        }
        
        // MARK: Alignment
        
        @inline(__always)
        static func alignment64(count: Int) -> Int {
            return count & 0x7FFFFFFFFFFFFFC0 // 0x7FFFFFFFFFFFFFC0 <-> 0b111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1100_0000
        }
        
        @inline(__always)
        static func alignment1k(count: Int) -> Int {
            return count & 0x7FFFFFFFFFFFFC00 // 0x7FFFFFFFFFFFFC00 <-> 0b111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1100_0000_0000
        }
    }
}
