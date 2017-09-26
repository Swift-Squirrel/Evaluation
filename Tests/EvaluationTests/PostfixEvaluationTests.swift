//
//  PostfixEvaluationTests.swift
//  EvaluationTests
//
//  Created by Filip Klembara on 9/26/17.
//

import XCTest
import Foundation
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
        guard let json = (try? JSONSerialization.jsonObject(with: postfix.data(using: .utf8)!)) as? [[String: Any]] else {
            XCTFail()
            return
        }
        guard json.count == 7 else {
            XCTFail(json.count.description)
            return
        }
        guard let three = get(from: json[0]) else {
            XCTFail()
            return
        }
        XCTAssertEqual(three.type, "int")
        XCTAssertEqual(three.typeValue, "Int")
        XCTAssertEqual(three.value, "3")

        guard let one = get(from: json[1]) else {
            XCTFail()
            return
        }
        XCTAssertEqual(one.type, "int")
        XCTAssertEqual(one.typeValue, "Int")
        XCTAssertEqual(one.value, "1")

        guard let add1 = get(from: json[2]) else {
            XCTFail()
            return
        }
        XCTAssertEqual(add1.type, "operation")
        XCTAssertEqual(add1.typeValue, "+")
        XCTAssertEqual(add1.value, "+")

        guard let stringCast1 = get(from: json[3]) else {
            XCTFail()
            return
        }
        XCTAssertEqual(stringCast1.type, "operation")
        XCTAssertEqual(stringCast1.typeValue, "String")
        XCTAssertEqual(stringCast1.value, "String")

        guard let twoone = get(from: json[4]) else {
            XCTFail()
            return
        }
        XCTAssertEqual(twoone.type, "double")
        XCTAssertEqual(twoone.typeValue, "Double")
        XCTAssertEqual(twoone.value, "2.1")

        guard let stringCast2 = get(from: json[5]) else {
            XCTFail()
            return
        }
        XCTAssertEqual(stringCast2.type, "operation")
        XCTAssertEqual(stringCast2.typeValue, "String")
        XCTAssertEqual(stringCast2.value, "String")

        guard let add2 = get(from: json[6]) else {
            XCTFail()
            return
        }
        XCTAssertEqual(add2.type, "operation")
        XCTAssertEqual(add2.typeValue, "+")
        XCTAssertEqual(add2.value, "+")
    }

    private func get(from data: [String: Any]) -> (type: String, typeValue: String, value: String)? {
        guard data.count == 2 else {
            XCTFail(data.count.description)
            return nil
        }
        guard let typeObj = data["type"] as? [String: String] else {
            XCTFail()
            return nil
        }
        guard typeObj.count == 1 else {
            XCTFail(typeObj.count.description)
            return nil
        }
        guard let value = data["value"] as? String else {
            XCTFail()
            return nil
        }
        return (typeObj.keys.first!, typeObj.values.first!, value)
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
