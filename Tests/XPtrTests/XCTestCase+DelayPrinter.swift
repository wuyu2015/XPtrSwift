import XCTest

extension XCTestCase {
    // 在 XCTestCase 子类中使用 pr(打印内容)
    func pr(_ s: Any, force: Bool = false) {
        if force {
            print(s)
        } else {
            XCTestDelayPrinter.shared.pr(s)
        }
    }
}
