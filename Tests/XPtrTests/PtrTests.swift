import XCTest
@testable import XPtr

final class PtrTests: XCTestCase {
    
    private var key: XPtr.SecretKey!
    
    override func setUp() {
        super.setUp()
        key = XPtr.SecretKey.random()
    }
    
    func test1() {
        let p = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        var xp = XPtr.Ptr(p, count: 1, key: key)
        XCTAssertEqual(xp.countType, .x8)
        for n in UInt8.min...UInt8.max {
            xp[0] = n
            XCTAssertEqual(xp[0], n)
        }
        p.deallocate()
    }
    
    func testX8() {
        for sz in 1...63 {
            let p = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
            var xp = XPtr.Ptr(p, count: sz, key: key)
            XCTAssertEqual(xp.countType, .x8)
            for i in 0..<sz {
                for n in UInt8.min...UInt8.max {
                    xp[i] = n
                    XCTAssertEqual(xp[i], n)
                }
            }
            p.deallocate()
        }
    }
    
    func testX64X8() {
        for _ in 0..<50 {
            let sz = Int.random(in: 64..<1023)
            let p: UnsafeMutablePointer<UInt8>! = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
            var xp = XPtr.Ptr(p, count: sz, key: key)
            XCTAssertEqual(xp.countType, sz % 64 == 0 ? .x64 : .x64X8)
            for _ in 0..<5 {
                let i = Int.random(in: 0..<sz)
                let n = UInt8.random(in: UInt8.min...UInt8.max)
                xp[i] = n
                XCTAssertEqual(xp[i], n)
            }
            p.deallocate()
        }
    }
    
    func testX1k() {
        let sz = 1024
        let p = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
        var xp = XPtr.Ptr(p, count: sz, key: key)
        XCTAssertEqual(xp.countType, .x1k)
        for _ in 0..<50 {
            let i = Int.random(in: 0..<sz)
            let n = UInt8.random(in: UInt8.min...UInt8.max)
            xp[i] = n
            XCTAssertEqual(xp[i], n)
        }
        p.deallocate()
    }
    
    func testX1kX8() {
        for sz in 1025...1087 {
            let p = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
            var xp = XPtr.Ptr(p, count: sz, key: key)
            XCTAssertEqual(xp.countType, .x1kX8)
            for _ in 0..<50 {
                let i = Int.random(in: 0..<sz)
                let n = UInt8.random(in: UInt8.min...UInt8.max)
                xp[i] = n
                XCTAssertEqual(xp[i], n)
            }
            p.deallocate()
        }
    }
    
    func testX1kX64X8() {
       for _ in 0..<50 {
           let sz = Int.random(in: 1088...2047)
           let p: UnsafeMutablePointer<UInt8>! = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
           var xp = XPtr.Ptr(p, count: sz, key: key)
           XCTAssertEqual(xp.countType, sz % 64 == 0 ? .x1kX64 : .x1kX64X8)
           for _ in 0..<5 {
               let i = Int.random(in: 0..<sz)
               let n = UInt8.random(in: UInt8.min...UInt8.max)
               xp[i] = n
               XCTAssertEqual(xp[i], n)
           }
           p.deallocate()
       }
   }
    
    func testX1kPlus() {
        for _ in 0..<50 {
            let sz = Int.random(in: 2...Int(UInt32.max) / 1024) * 1024
            let p = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
            var xp = XPtr.Ptr(p, count: sz, key: key)
            XCTAssertEqual(xp.countType, .x1kPlus)
            for _ in 0..<50 {
                let i = Int.random(in: 0..<sz)
                let n = UInt8.random(in: UInt8.min...UInt8.max)
                xp[i] = n
                XCTAssertEqual(xp[i], n)
            }
            p.deallocate()
        }
    }
    
    func testX1kPlusX8() {
        for _ in 0..<50 {
            let sz = Int.random(in: 2...Int(UInt32.max) / 1024) * 1024 + Int.random(in: 1...63)
            let p = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
            var xp = XPtr.Ptr(p, count: sz, key: key)
            XCTAssertEqual(xp.countType, .x1kPlusX8)
            for _ in 0..<50 {
                let i = Int.random(in: 0..<sz)
                let n = UInt8.random(in: UInt8.min...UInt8.max)
                xp[i] = n
                XCTAssertEqual(xp[i], n)
            }
            p.deallocate()
        }
    }
    
    func testX1kPlusX64() {
        for _ in 0..<50 {
            let sz = Int.random(in: 2...Int(UInt32.max) / 1024) * 1024 + Int.random(in: 1...15) * 64
            let p = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
            var xp = XPtr.Ptr(p, count: sz, key: key)
            XCTAssertEqual(xp.countType, .x1kPlusX64)
            for _ in 0..<50 {
                let i = Int.random(in: 0..<sz)
                let n = UInt8.random(in: UInt8.min...UInt8.max)
                xp[i] = n
                XCTAssertEqual(xp[i], n)
            }
            p.deallocate()
        }
    }
    
    func testX1kPlusX64X8() {
        for _ in 0..<50 {
            let sz = Int.random(in: 2...Int(UInt32.max) / 1024) * 1024 + Int.random(in: 1...15) * 64 + Int.random(in: 1...63)
            let p = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
            var xp = XPtr.Ptr(p, count: sz, key: key)
            XCTAssertEqual(xp.countType, .x1kPlusX64X8)
            for _ in 0..<50 {
                let i = Int.random(in: 0..<sz)
                let n = UInt8.random(in: UInt8.min...UInt8.max)
                xp[i] = n
                XCTAssertEqual(xp[i], n)
            }
            p.deallocate()
        }
    }
    
    func testRandom() {
        for _ in 0..<50 {
            let sz = Int.random(in: 1...4096)
            let p0 = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
            let p = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
            var xp = XPtr.Ptr(p, count: sz, key: key)
            for i in 0..<sz {
                let n = UInt8.random(in: UInt8.min...UInt8.max)
                p0[i] = n
                xp[i] = n
            }
            for i in 0..<sz {
                XCTAssertEqual(p0[i], xp[i])
            }
            p.deallocate()
        }
    }
}
