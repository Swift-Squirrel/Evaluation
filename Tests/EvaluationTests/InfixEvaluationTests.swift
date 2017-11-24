import XCTest
@testable import Evaluation

class InfixEvaluationTests: XCTestCase {
    func testNil() {
        let expr = "action == \"login\" || action == nil"
        let res = expr.evaluateAsBool()
        guard let bool = res else {
            XCTFail()
            return
        }
        XCTAssertTrue(bool)
    }

    func testLong() {
        let expression = "4 + Int(0.5 * Double(2)) / Int(\"1\" + \"\") "
            + "< Int(Double(41) * a + (Double(\"smthng\") ?? 1.0)) "
            + "&& c.count == Int(7.0 / 2.0) && (c.male == true || c.name == \"John\")"

        guard let eval = try? InfixEvaluation(expression: expression) else {
            XCTFail()
            return
        }
        let data: [String: Any] = [
            "a": 2.4,
            "b": [1,1],
            "c": [
                "d": "damdam",
                "name": "John",
                "male": true
            ]
        ]
        XCTAssertNoThrow(try eval.evaluate(with: data))
        guard let a = (try? eval.evaluate(with: data)) as? Bool else {
            XCTFail()
            return
        }
        XCTAssertTrue(a)
    }

    func testToInt() {
        let expression = "21 + Int(1.0 * 4.01 * Double(Int(\"4\") / 1)) % 2"

        guard let eval = try? InfixEvaluation(expression: expression) else {
            XCTFail()
            return
        }
        let data: [String: Any] = [
            "a": 2.4,
            "b": [1,1],
            "c": [
                "d": "damdam",
                "name": "John",
                "male": true
            ]
        ]
        XCTAssertNoThrow(try eval.evaluate(with: data))
        guard let a = (try? eval.evaluate()) as? Int else {
            XCTFail()
            return
        }
        XCTAssertTrue(a == 21)
    }

    func testVarName() {
        let expression = "_a + Int(c._d * 4.01)"

        guard let eval = try? InfixEvaluation(expression: expression) else {
            XCTFail()
            return
        }
        let data: [String: Any] = [
            "_a": 2,
            "b": [1,1],
            "c": [
                "_d": 2.0,
                "name": "John",
                "male": true
            ]
        ]
        XCTAssertNoThrow(try eval.evaluate(with: data))
        guard let a = (try? eval.evaluate(with: data)) as? Int else {
            XCTFail()
            return
        }
        XCTAssertTrue(a == 10)
    }
    
    static var allTests = [
        ("testLong", testLong),
        ("testToInt", testToInt),
        ("testNil", testNil),
        ("testVarName", testVarName)
    ]
}
