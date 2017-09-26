//
//  PostfixEvaluation.swift
//  Evaluation
//
//  Created by Filip Klembara on 9/26/17.
//

import Foundation

/// Postfix evaluation
public class PostfixEvaluation {

    var postfix = [Token]()

    /// Evaluation tokens
    public struct Token {
        /// Evaluation token types
        ///
        /// - operation: Operation
        /// - open: (
        /// - close: )
        /// - double: Double value
        /// - int: Int value
        /// - bool: Bool value
        /// - string: String value
        /// - variable: Variable
        /// - bottom: Bottom of stack $
        public enum TokenType { // swiftlint:disable:this nesting
            case operation(oper: OperationProtocol)
            case open
            case close
            case double
            case int
            case bool
            case string
            case variable
            case bottom
        }

        /// Token type
        public let type: TokenType
        /// Token value
        public let value: String
    }

    /// Construct from tokens in postfix
    ///
    /// - Parameter postfix: Postfix tokens
    public init(postfix: [Token]) {
        self.postfix = postfix
    }
}

extension PostfixEvaluation {
    private func getValue(name: String, from data: [String: Any]) -> Any? {
        if name.contains(".") {
            let separated = name.components(separatedBy: ".")
            if separated.count == 2 {
                if separated[1] == "count" {
                    if let arr = data[separated[0]] as? [Any] {
                        return arr.count
                    } else if let dir = data[separated[0]] as? [String: Any] {
                        return dir.count
                    }
                }
            }
            guard let newData = data[separated[0]] as? [String: Any] else {
                return nil
            }
            var seps = separated
            seps.removeFirst()
            return getValue(name: seps.joined(separator: "."), from: newData)
        } else {
            return data[name]
        }
    }


    /// Evaluate expression and return result
    ///
    /// - Parameter data: Dictionary with variables used in expression
    /// - Returns: result of expression
    /// - Throws: semantic and syntax error: `EvaluationError`
    public func evaluate(with data: [String: Any] = [:]) throws -> Any? {
        // swiftlint:disable:previous function_body_length
        let stack = Stack<Any?>()

        for token in postfix {
            switch token.type {
            case .operation(let operation):
                switch operation.operation {
                case .binary(let binary):
                    guard stack.count > 1 else {
                        throw EvaluationError(kind: .missingValue(forOperand: operation.symbol))
                    }
                    let second = stack.pop()!
                    let first = stack.pop()!
                    if second == nil || first == nil {
                        if operation.symbol == "==" {
                            stack.push(item: second == nil && first == nil)
                        } else if operation.symbol == "!=" {
                            stack.push(item: !(second == nil && first == nil))
                        } else {
                            throw EvaluationError(
                                kind: .nilFound(expr: "\(first ?? "nil")\(token.value)\(second ?? "nil")"))
                        }
                    } else {
                        stack.push(item: try binary(first!, second!))
                    }
                case .binaryNilCoalescing(let cloalescing):
                    guard stack.count > 1 else {
                        throw EvaluationError(kind: .missingValue(forOperand: operation.symbol),
                                              description: "Missing value for binary operation")
                    }
                    let second = stack.pop()!
                    let first = stack.pop()!
                    stack.push(item: cloalescing(first, second))
                case .unary(let unary):
                    guard stack.count > 0 else {
                        throw EvaluationError(kind: .missingValue(forOperand: operation.symbol))
                    }
                    let first = stack.pop()!
                    if first == nil {
                        throw EvaluationError(
                            kind: .nilFound(expr: token.value + String(describing: first)))
                    }
                    stack.push(item: try unary(first!))
                case .cast(let cast):
                    guard stack.count > 0 else {
                        throw EvaluationError(kind: .missingValue(forOperand: operation.symbol))
                    }
                    let first = stack.pop()!
                    if first == nil {
                        throw EvaluationError(
                            kind: .nilFound(expr: token.value + String(describing: first)))
                    }
                    stack.push(item: cast(first!))
                }
            case .bool:
                stack.push(item: token.value == "true")
            case .double:
                stack.push(item: Double(token.value)!)
            case .int:
                stack.push(item: Int(token.value)!)
            case .string:
                stack.push(item: token.value)
            default:
                stack.push(item: getValue(name: token.value, from: data))
            }
        }
        guard !stack.isEmpty() else {
            throw EvaluationError(kind: .missingValue(forOperand: "result"), description: "There is no final result")
        }
        let result = stack.pop()!
        guard stack.isEmpty() else {
            throw EvaluationError(kind: .syntaxError, description: "There is more than one value in final stack")
        }
        return result
    }
}
