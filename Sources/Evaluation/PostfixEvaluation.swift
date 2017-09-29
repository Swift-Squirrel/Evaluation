//
//  PostfixEvaluation.swift
//  Evaluation
//
//  Created by Filip Klembara on 9/26/17.
//

import Foundation

/// Postfix evaluation
public class PostfixEvaluation {
    public internal(set) var postfix: [Token]

    /// Serialized postfix in JSON format
    ///
    /// - Returns: Data representation of postfix
    /// - Throws: JSONEncoder errors
    public func serializedPostfix() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(postfix)
    }

    /// Serialized postfix in JSON format
    ///
    /// - Returns: Data representation of postfix
    /// - Throws: JSONEncoder errors
    public func serializedPostfix() throws -> String {
        let data: Data = try serializedPostfix()
        guard let string = String(data: data, encoding: .utf8) else {
            throw EvaluationError(kind: .encodingError, description: "Can not represent data in utf8")
        }
        return string
    }

    /// Evaluation tokens
    public struct Token: Codable {
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
        enum TokenType { // swiftlint:disable:this nesting
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
        let type: TokenType
        /// Token value
        let value: String
    }

    public init(postfix: [Token]) {
        self.postfix = postfix
    }

    /// Construct from string representing postfix tokens in JSON
    ///
    /// - Parameter postfix: JSON representation of postfix tokens
    /// - Throws: EvaluationError(kind: .decodingError) and JSONDecoder errors
    public convenience init(postfix: String) throws {
        guard let data = postfix.data(using: .utf8) else {
            throw EvaluationError(kind: .decodingError, description: "Can not represent string as data with utf8")
        }
        try self.init(postfixData: data)
    }

    /// Construct from data representing postfix tokens in JSON
    ///
    /// - Parameter data: JSON representation of postfix tokens
    /// - Throws: JSONDecoder errors
    public init(postfixData data: Data) throws {
        let decoder = JSONDecoder()
        self.postfix = try decoder.decode([Token].self, from: data)
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

// MARK: - Codable tokens
extension PostfixEvaluation.Token.TokenType: Codable {
    private enum CodingKeys: String, CodingKey {
        case operation
        case double
        case int
        case bool
        case string
        case variable
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .operation) {
            self = .operation(oper: try getOperationBy(symbol: value))
            return
        }
        if values.contains(.double) {
            self = .double
            return
        }
        if values.contains(.int) {
            self = .int
            return
        }
        if values.contains(.bool) {
            self = .bool
            return
        }
        if values.contains(.string) {
            self = .string
            return
        }
        if values.contains(.variable) {
            self = .variable
            return
        }
        throw EvaluationError(kind: .decodingError)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .operation(let operation):
            try container.encode(operation.symbol, forKey: .operation)
        case .double:
            try container.encode("Double", forKey: .double)
        case .int:
            try container.encode("Int", forKey: .int)
        case .bool:
            try container.encode("Bool", forKey: .bool)
        case .string:
            try container.encode("String", forKey: .string)
        case .variable:
            try container.encode("Variable", forKey: .variable)
        default:
            throw EvaluationError(kind: .encodingError)
        }
    }
}

// swiftlint:disable:next function_body_length
fileprivate func getOperationBy(symbol: String) throws -> OperationProtocol {
    switch symbol {
    case "+":
        return AdditionOperator()
    case "-":
        return SubOperator()
    case "*":
        return MulOperator()
    case "/":
        return DivOperator()
    case "%":
        return ModOperator()
    case "==":
        return EqualOperator()
    case "!=":
        return NotEqualOperator()
    case "<":
        return LessOperator()
    case "<=":
        return LessEqualOperator()
    case ">":
        return GreaterOperator()
    case ">=":
        return GreaterEqualOperator()
    case "&&":
        return AndOperator()
    case "||":
        return OrOperator()
    case  "!":
        return NotOperator()
    case "??":
        return NilCoalescingOperator()
    case "String":
        return StringCast()
    case "Int":
        return IntCast()
    case "UInt":
        return UIntCast()
    case "Double":
        return DoubleCast()
    case "Float":
        return FloatCast()
    case "Bool":
        return BoolCast()
    default:
        throw EvaluationError(kind: .unknownOperation(operation: symbol))
    }
}
