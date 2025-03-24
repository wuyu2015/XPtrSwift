import XCTest
@testable import XPtr

final class SecretKeyTests: XCTestCase {
    
    // MARK: Print
    
    func testPrintRandomX8() {
        print(XPtr.SecretKey.randomX8())
    }
    
    func testPrintRandomX64() {
        print(XPtr.SecretKey.randomX64())
    }
    
    func testPrintRandomX1K() {
        print(XPtr.SecretKey.randomX1K())
    }
    
    func testPrintFormattedX8() {
        print(XPtr.SecretKey.random().formatX8(comment: true))
    }
    
    func testPrintFormattedH8() {
        print(XPtr.SecretKey.random().formatH8(comment: true))
    }
    
    func testPrintFormattedX64() {
        print(XPtr.SecretKey.random().formatX64(comment: true))
    }
    
    func testPrintFormattedH64() {
        print(XPtr.SecretKey.random().formatH64(comment: true))
    }
    
    func testPrintFormattedX1K() {
        print(XPtr.SecretKey.random().formatX1K())
    }
    
    func testPrintFormattedH1K() {
        print(XPtr.SecretKey.random().formatH1K())
    }
    
    func testPrintDump() {
        print(XPtr.SecretKey.random().dump())
    }
    
    func testPrintSumTo() {
        for count in 1...64 {
            print(XPtr.SecretKey.sumTo(count))
        }
    }
    
    func testPrintOffset8() {
        for count in 1...65 {
            print("count=\(count),ofset8=\(XPtr.SecretKey.offset8(count: count))")
        }
    }
    
    func testPrintOffset64() {
        for count in 1...1025 {
            print("count=\(count),ofset64=\(XPtr.SecretKey.offset64(count: count))")
        }
    }
    
    func testPrintAlignment64() {
        for count in 1...2049 {
            print("count=\(count),alignment64=\(XPtr.SecretKey.alignment64(count: count))")
        }
    }
    
    // MARK: Random
    
    func testRandomX8() {
        let result = XPtr.SecretKey.randomX8()
        XCTAssertEqual(result[0...2], [0, 1, 0]) // 固定前 3 位是 [0, 1, 0]
        XCTAssertEqual(result.count, XPtr.SecretKey.count8) // 总长度
        var index = 0
        for len in 1...63 {
            let set = Set(result[index..<index + len])
            XCTAssertEqual(set.count, len)
            for n in 0..<len {
                XCTAssertTrue(set.contains(UInt8(n)))
            }
            index += len
        }
    }
    
    func testRandomX64() {
        let result = XPtr.SecretKey.randomX64()
        XCTAssertEqual(result.count, XPtr.SecretKey.count64) // 总长度
        var index = 0
        for len in stride(from: 64, to: 1024, by: 64) {
            let set = Set(result[index..<index + len])
            XCTAssertEqual(set.count, len)
            for n in 0..<len {
                XCTAssertTrue(set.contains(UInt16(n)))
            }
            index += len
        }
    }
    
    func testRandomX1K() {
        let result = XPtr.SecretKey.randomX1K()
        XCTAssertEqual(result.count, 1024) // 总长度
        let set = Set<UInt16>(result[0..<1024])
        XCTAssertEqual(set.count, 1024)
        for n in 0..<1024 {
            XCTAssertTrue(set.contains(UInt16(n)))
        }
    }
    
    func testRandomH8() {
        let result = XPtr.SecretKey.randomH8()
        XCTAssertEqual(result.count, XPtr.SecretKey.count8) // 总长度
        for n in result {
            XCTAssertGreaterThanOrEqual(n, 0)
            XCTAssertLessThanOrEqual(n, 255)
        }
    }
    
    func testRandomH64() {
        let result = XPtr.SecretKey.randomH64()
        XCTAssertEqual(result.count, XPtr.SecretKey.count64) // 总长度
        for n in result {
            XCTAssertGreaterThanOrEqual(n, 0)
            XCTAssertLessThanOrEqual(n, 255)
        }
    }
    
    func testRandomH1K() {
        let result = XPtr.SecretKey.randomH1K()
        XCTAssertEqual(result.count, 1024) // 总长度
        for n in result {
            XCTAssertGreaterThanOrEqual(n, 0)
            XCTAssertLessThanOrEqual(n, 255)
        }
    }
    
    // MARK: Offset
    
    func testSumTo() {
        XCTAssertEqual(XPtr.SecretKey.sumTo(0), 0)
        XCTAssertEqual(XPtr.SecretKey.sumTo(1), 1)
        XCTAssertEqual(XPtr.SecretKey.sumTo(2), 3)
        XCTAssertEqual(XPtr.SecretKey.sumTo(3), 6)
        XCTAssertEqual(XPtr.SecretKey.sumTo(4), 10)
        XCTAssertEqual(XPtr.SecretKey.sumTo(5), 15)
    }
    
    func testOffset8() {
        XCTAssertEqual(XPtr.SecretKey.offset8(count: 1), 0)
        XCTAssertEqual(XPtr.SecretKey.offset8(count: 2), 1)
        XCTAssertEqual(XPtr.SecretKey.offset8(count: 3), 3)
        XCTAssertEqual(XPtr.SecretKey.offset8(count: 4), 6)
        XCTAssertEqual(XPtr.SecretKey.offset8(count: 5), 10)
        XCTAssertEqual(XPtr.SecretKey.offset8(count: 6), 15)
    }
    
    func testOffset64() {
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 0), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 1), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 2), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 63), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 64), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 65), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 66), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 67), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 127), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 128), 64)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 129), 64)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 130), 64)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 191), 64)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 192), 192)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 193), 192)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 194), 192)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 255), 192)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 256), 384)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 257), 384)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 258), 384)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 959), 5824)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 960), 6720)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 961), 6720)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 962), 6720)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 1023), 6720)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 1024), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 1025), 0)
        XCTAssertEqual(XPtr.SecretKey.offset64(count: 1026), 0)
    }
    
    // MARK: Alignment
    
    func testAlignment64() {
        for n in 0...63 {
            XCTAssertEqual(XPtr.SecretKey.alignment64(count: n), 0)
        }
        for n in 64...127 {
            XCTAssertEqual(XPtr.SecretKey.alignment64(count: n), 64)
        }
        for n in 128...191 {
            XCTAssertEqual(XPtr.SecretKey.alignment64(count: n), 128)
        }
        for n in 0x4000000000000000...0x4000000000000000 + 63 {
            XCTAssertEqual(XPtr.SecretKey.alignment64(count: n), 0x4000000000000000)
        }
        for n in 0x4000000000000000 + 64...0x4000000000000000 + 64 + 63 {
            XCTAssertEqual(XPtr.SecretKey.alignment64(count: n), 0x4000000000000000 + 64)
        }
        for n in 0x7FFFFFFFFFFFFFC0...0x7FFFFFFFFFFFFFC0 + 63 {
            XCTAssertEqual(XPtr.SecretKey.alignment64(count: n), 0x7FFFFFFFFFFFFFC0)
        }
    }
    
    func testAlignment1k() {
        for n in 0...1023 {
            XCTAssertEqual(XPtr.SecretKey.alignment1k(count: n), 0)
        }
        for n in 1024...2047 {
            XCTAssertEqual(XPtr.SecretKey.alignment1k(count: n), 1024)
        }
        for n in 2048...3071 {
            XCTAssertEqual(XPtr.SecretKey.alignment1k(count: n), 2048)
        }
        for n in 0x4000000000000000...0x4000000000000000 + 1023 {
            XCTAssertEqual(XPtr.SecretKey.alignment1k(count: n), 0x4000000000000000)
        }
        for n in 0x4000000000000000 + 1024...0x4000000000000000 + 1024 + 1023 {
            XCTAssertEqual(XPtr.SecretKey.alignment1k(count: n), 0x4000000000000000 + 1024)
        }
        for n in 0x7FFFFFFFFFFFFC00...0x7FFFFFFFFFFFFC00 + 1023 {
            XCTAssertEqual(XPtr.SecretKey.alignment1k(count: n), 0x7FFFFFFFFFFFFC00)
        }
    }
}
