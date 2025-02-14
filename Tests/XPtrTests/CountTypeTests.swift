import XCTest
@testable import XPtr

final class CountTypeTests: XCTestCase {
    
    func testX8() {
        for n in 1...63 {
            XCTAssertEqual(XPtr.CountType(count: n), .x8)
        }
        for _ in 0..<1000 {
            XCTAssertNotEqual(XPtr.CountType(count: Int.random(in: 64...Int(UInt32.max))), .x8)
        }
    }
    
    func testX64X8() {
        for n in 64...1023 {
            if n % 64 == 0 {
                XCTAssertEqual(XPtr.CountType(count: n), .x64)
            } else {
                XCTAssertEqual(XPtr.CountType(count: n), .x64X8)
            }
        }
        for _ in 0..<1000 {
            let n1 = Int.random(in: 1...63)
            XCTAssertNotEqual(XPtr.CountType(count: n1), .x64)
            XCTAssertNotEqual(XPtr.CountType(count: n1), .x64X8)
            
            let n2 = Int.random(in: 1024...Int(UInt32.max))
            XCTAssertNotEqual(XPtr.CountType(count: n2), .x64)
            XCTAssertNotEqual(XPtr.CountType(count: n2), .x64X8)
        }
    }
    
    func testX1k() {
        XCTAssertEqual(XPtr.CountType(count: 1024), .x1k)
        XCTAssertNotEqual(XPtr.CountType(count: 2048), .x1k)
        for _ in 0..<1000 {
            XCTAssertNotEqual(XPtr.CountType(count: Int.random(in: 1...1023)), .x1k)
            XCTAssertNotEqual(XPtr.CountType(count: Int.random(in: 1025...Int(UInt32.max))), .x1k)
        }
    }
    
    func testX1kX8() {
        for n in 1025...1087 {
             XCTAssertEqual(XPtr.CountType(count: n), .x1kX8)
        }
        for _ in 0..<1000 {
            XCTAssertNotEqual(XPtr.CountType(count: Int.random(in: 1...1024)), .x1kX8)
            XCTAssertNotEqual(XPtr.CountType(count: Int.random(in: 1025...Int(UInt32.max))), .x1kX8)
        }
    }
    
    func testX1kX64X8() {
        for n in 1088...2047 {
            if n % 64 == 0 {
                XCTAssertEqual(XPtr.CountType(count: n), .x1kX64)
            } else {
                XCTAssertEqual(XPtr.CountType(count: n), .x1kX64X8)
            }
        }
        for _ in 0..<1000 {
            let n1 = Int.random(in: 1...63)
            XCTAssertNotEqual(XPtr.CountType(count: n1), .x1kX64)
            XCTAssertNotEqual(XPtr.CountType(count: n1), .x1kX64X8)
            
            let n2 = Int.random(in: 1024...Int(UInt32.max))
            XCTAssertNotEqual(XPtr.CountType(count: n2), .x1kX64)
            XCTAssertNotEqual(XPtr.CountType(count: n2), .x1kX64X8)
        }
    }
    
    func testX1kPlus() {
        for n in 1...2047 {
            XCTAssertNotEqual(XPtr.CountType(count: n), .x1kPlus)
        }
        for n in stride(from: 2048, through: 65536, by: 1024) {
            XCTAssertEqual(XPtr.CountType(count: n), .x1kPlus)
        }
        for n in stride(from: Int(UInt32.max) + 1 - 10240, through: Int(UInt32.max), by: 1024) {
            XCTAssertEqual(XPtr.CountType(count: n), .x1kPlus)
        }
        for _ in 0..<1000 {
            let n = Int.random(in: 2048...Int(UInt32.max))
            if n % 1024 == 0 {
                XCTAssertEqual(XPtr.CountType(count: n), .x1kPlus)
            } else {
                XCTAssertNotEqual(XPtr.CountType(count: n), .x1kPlus)
            }
        }
    }
    
    func testX1kPlusX8() {
        for n in 1...2048 {
            XCTAssertNotEqual(XPtr.CountType(count: n), .x1kPlusX8)
        }
        for n in 2049...2111 {
            XCTAssertEqual(XPtr.CountType(count: n), .x1kPlusX8)
        }
        for n in 3073...3135 {
            XCTAssertEqual(XPtr.CountType(count: n), .x1kPlusX8)
        }
        for n in 4294966273...4294966335 {
            XCTAssertEqual(XPtr.CountType(count: n), .x1kPlusX8)
        }
        for _ in 0..<1000 {
            let n = Int.random(in: 2049...Int(UInt32.max))
            let m1024 = n % 1024
            
            if m1024 == 0 {
                XCTAssertEqual(XPtr.CountType(count: n), .x1kPlus)
            } else if m1024 <= 63 {
                XCTAssertEqual(XPtr.CountType(count: n), .x1kPlusX8)
            }
        }
    }
    
    func testX1kPlusX64X8() {
        for n in 1...2048 {
            XCTAssertNotEqual(XPtr.CountType(count: n), .x1kPlusX64)
            XCTAssertNotEqual(XPtr.CountType(count: n), .x1kPlusX64X8)
        }
        for _ in 0..<1000 {
            let n = Int.random(in: 2049...Int(UInt32.max))
            let countType = XPtr.CountType(count: n)
            if countType == .x1kPlusX64 {
                XCTAssertEqual(n % 64, 0)
            } else if countType != .x1kPlus && countType != .x1kPlusX8 {
                XCTAssertEqual(countType, .x1kPlusX64X8)
            }
        }
    }
}
