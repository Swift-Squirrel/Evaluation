//
//  PostfixEvaluationTests.swift
//  EvaluationTests
//
//  Created by Filip Klembara on 9/26/17.
//

import XCTest
@testable import Evaluation

class PostfixEvaluationTests: XCTestCase {
    let expString = """
        [{"type":{"int":"Int"},"value":"3"},{"type":{"int":"Int"},"value":"1"},{"type":{"operation":"+"},"value":"+"},{"type":{"operation":"String"},"value":"String"},{"type":{"double":"Double"},"value":"2.1"},{"type":{"operation":"String"},"value":"String"},{"type":{"operation":"+"},"value":"+"}]
        """

    func testEncoding() {
        guard let eval = try? InfixEvaluation(expression: "String(3 + 1) + String(2.1)") else {
            XCTFail()
            return
        }

        guard let postfix: String = try? eval.serializedPostfix() else {
            XCTFail()
            return
        }
        XCTAssertEqual(postfix, expString)
    }

    func testDecoding() {
        guard let eval = try? PostfixEvaluation(postfix: expString) else {
            XCTFail()
            return
        }
        guard let resultAny = try? eval.evaluate() else {
            XCTFail()
            return
        }
        guard let result = resultAny as? String else {
            XCTFail()
            return
        }
        XCTAssertEqual(result, "42.1")
    }

    static let allTests = [
        ("testEncoding", testEncoding),
        ("testDecoding", testDecoding)
    ]
}
