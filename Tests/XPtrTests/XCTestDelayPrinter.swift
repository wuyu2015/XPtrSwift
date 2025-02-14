import XCTest

class XCTestDelayPrinter {
    static let shared = XCTestDelayPrinter()
    
    // 使用方法：XCTestDelayPrinter.shared.p(打印内容)
    private init() {
        XCTestObservationCenter.shared.addTestObserver(XCTestDelayPrinterObserver())
    }
    
    private var buf: [Any] = []
    
    func pr(_ item: Any) {
        // 延迟输出打印内容
        buf.append(item)
    }
    
    func clear() {
        buf.removeAll()
    }
    
    func printAll() {
        buf.forEach {
            print($0)
        }
    }
}

final class XCTestDelayPrinterObserver: NSObject, XCTestObservation {
    private var isSelectedTests = false
    
    func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        if !isSelectedTests {
            switch testSuite.name {
            case "Selected tests":
                // 单独点击测试用例：标记
                isSelectedTests = true
            case "All tests":
                // ⌘ + U：清除打印内容
                XCTestDelayPrinter.shared.clear()
            default:
                break
            }
            
        }
    }
    
    func testBundleDidFinish(_ testBundle: Bundle) {
        if isSelectedTests {
            // 单独点击测试用例：输出打印
            XCTestDelayPrinter.shared.printAll()
        }
        // ⌘ + U：不输出打印
        XCTestDelayPrinter.shared.clear()
    }
}
