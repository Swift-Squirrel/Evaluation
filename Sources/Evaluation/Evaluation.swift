//
//  Evaluation.swift
//  Evaluation
//
//  Created by Filip Klembara on 8/5/17.
//
//

import Foundation

/// Evaluation class
public class Evaluation {
    private let string: String
    private var tokens = [Token]()
    private let chars: [String]

    private var _postfix = [Token]()

    /// Postfix notation of given expression
    private var stringPostfix: [String]? = nil

    /// String representation of postfix
    public var postfix: [String] {
        if stringPostfix == nil {
            stringPostfix = _postfix.map({ $0.value })
        }
        return stringPostfix!
    }

    private struct Token {
        // swiftlint:disable:next nesting
        enum TokenType {
            case operation(oper: OperationProtocol)
            case open
            case close
            case double
            case int
            case bool
            case string
            case variable
            case bottom
            case stringCast
            case intCast
            case uintCast
            case boolCast
            case doubleCast
            case floatCast
        }

        let type: TokenType
        let value: String
    }


    /// Perform lexical analysis and makes postfix notation of given expression
    ///
    /// - Parameter string: expression
    /// - Throws: lexical and syntax error as `EvaluationError`
    public init(expression string: String) throws {
        self.string = string
        chars = Array(string.characters).map({ String(describing: $0) })
        try parseTokens(string: string)
        try makePostfix()
    }

    private var index = -1
    private func nextChar() -> String? {
        if index + 1 == chars.count {
            return nil
        }
        index += 1
        return chars[index]
    }

    private func charBack() {
        index -= 1
    }

    // swiftlint:disable:next function_body_length
    private func parseVariable() throws {
        var isStarting = true
        var cnt = ""
        while let char = nextChar() {
            if isStarting {
                guard isChar(char: char) else {
                    throw EvaluationError(kind: .unexpectedCharacter(reading: cnt,
                                                                     expected: "variable identifier",
                                                                     got: char))
                }
                cnt += char
                isStarting = false
            } else {
                if isChar(char: char) || isNumber(char: char) || char == "_" {
                    cnt += char
                } else if char == "." {
                    cnt += char
                    isStarting = true
                } else {
                    charBack()
                    break
                }
            }
        }
        guard !isStarting else {
            throw EvaluationError(kind: .unexpectedEnd(reading: cnt),
                                  description: "Unexpected end while reading variable: \(cnt)")
        }

        switch cnt {
        case "true", "false":
            addToken(type: .bool, value: cnt)
        case "String":
            if let char = nextChar(), char == "(" {
                let cnt = try variableCast()
                addToken(type: .stringCast, value: cnt)
            } else {
                fallthrough
            }
        case "Int":
            if let char = nextChar(), char == "(" {
                let cnt = try variableCast()
                addToken(type: .intCast, value: cnt)
            } else {
                fallthrough
            }
        case "UInt":
            if let char = nextChar(), char == "(" {
                let cnt = try variableCast()
                addToken(type: .uintCast, value: cnt)
            } else {
                fallthrough
            }
        case "Bool":
            if let char = nextChar(), char == "(" {
                let cnt = try variableCast()
                addToken(type: .boolCast, value: cnt)
            } else {
                fallthrough
            }
        case "Double":
            if let char = nextChar(), char == "(" {
                let cnt = try variableCast()
                addToken(type: .doubleCast, value: cnt)
            } else {
                fallthrough
            }
        case "Float":
            if let char = nextChar(), char == "(" {
                let cnt = try variableCast()
                addToken(type: .floatCast, value: cnt)
            } else {
                fallthrough
            }
        default:
            guard !cnt.components(separatedBy: ".").contains(where: { $0 == "false" || $0 == "true" }) else {
                throw EvaluationError(kind: .syntaxError, description: "variable name can not use false|true as part")
            }
            addToken(type: .variable, value: cnt)
        }

    }

    private func variableCast() throws -> String {
        var opened = 1
        var cnt = ""
        while opened > 0, let char = nextChar() {
            if char == ")" && opened == 1 {
                opened -= 1
            } else {
                if char == "(" {
                    opened += 1
                } else if char == ")" {
                    opened -= 1
                }
                cnt += char
            }
        }
        guard opened == 0 else {
            throw EvaluationError(kind: .unexpectedEnd(reading: cnt),
                                  description: "Unexpected end while reading expression: \(cnt)")
        }
        return cnt
    }

    private func parseNumber(char: String) throws {
        var cnt = char
        var type: Token.TokenType = .int
        var breaked = false
        while !breaked, let char = nextChar() {
            if isNumber(char: char) {
                cnt += char
            } else if char == "." {
                cnt += char
                type = .double
                guard let char = nextChar() else {
                    throw EvaluationError(kind: .unexpectedEnd(reading: cnt), description: "expecting number: \(cnt)")
                }
                guard isNumber(char: char) else {
                    throw EvaluationError(kind: .unexpectedCharacter(reading: cnt, expected: "number", got: char))
                }
                cnt += char
                while !breaked, let char = nextChar() {
                    if isNumber(char: char) {
                        cnt += char
                    } else {
                        charBack()
                        breaked = true
                    }
                }
            } else {
                charBack()
                breaked = true
            }
        }
        addToken(type: type, value: cnt)
    }

    private func isChar(char: String) -> Bool {
        guard let char = char.unicodeScalars.first else {
            return false
        }
        guard char.isASCII else {
            return false
        }
        let num = char.value
        if (num > 96 && num < 123) || (num > 64 && num < 91) {
            return true
        }
        return false
    }

    private func addToken(type: Token.TokenType, value: String) {
        tokens.append(Token(type: type, value: value))
    }

    private func isNumber(char: String) -> Bool {
        return Int(char) != nil
    }
}

extension Evaluation {

    // swiftlint:disable function_body_length
    private func parseTokens(string: String) throws {
        while let char = nextChar() {
            switch char {
            case " ":
                break
            case "(":
                addToken(type: .open, value: "(")
            case ")":
                addToken(type: .close, value: ")")
            case "+":
                addToken(type: .operation(oper: AdditionOperator()), value: "+")
            case "-":
                addToken(type: .operation(oper: SubOperator()), value: "-")
            case "*":
                addToken(type: .operation(oper: MulOperator()), value: "*")
            case "/":
                addToken(type: .operation(oper: DivOperator()), value: "/")
            case "%":
                addToken(type: .operation(oper: ModOperator()), value: "%")
            case "<":
                guard let char = nextChar() else {
                    throw EvaluationError(kind: .unexpectedEnd(reading: "<"))
                }
                if char == "=" {
                    addToken(type: .operation(oper: LessEqualOperator()), value: "<=")
                } else {
                    addToken(type: .operation(oper: LessOperator()), value: "<")
                    charBack()
                }
            case ">":
                guard let char = nextChar() else {
                    throw EvaluationError(kind: .unexpectedEnd(reading: ">"))
                }
                if char == "=" {
                    addToken(type: .operation(oper: GreaterEqualOperator()), value: ">=")
                } else {
                    addToken(type: .operation(oper: GreaterOperator()), value: ">")
                    charBack()
                }
            case "=":
                guard let char = nextChar() else {
                    throw EvaluationError(kind: .unexpectedEnd(reading: "="))
                }
                guard char == "=" else {
                    throw EvaluationError(kind: .unexpectedCharacter(reading: "=", expected: "=", got: char))
                }
                addToken(type: .operation(oper: EqualOperator()), value: "==")

            case "!":
                guard let char = nextChar() else {
                    throw EvaluationError(kind: .unexpectedEnd(reading: "!"))
                }
                if char == "=" {
                    addToken(type: .operation(oper: NotEqualOperator()), value: "!=")
                } else {
                    addToken(type: .operation(oper: NotOperator()), value: "!")
                    charBack()
                }
            case "&":
                guard let char = nextChar() else {
                    throw EvaluationError(kind: .unexpectedEnd(reading: "&"))
                }
                guard char == "&" else {
                    throw EvaluationError(kind: .unexpectedCharacter(reading: "&", expected: "&", got: char))
                }
                addToken(type: .operation(oper: AndOperator()), value: "&&")
            case "|":
                guard let char = nextChar() else {
                    throw EvaluationError(kind: .unexpectedEnd(reading: "|"),
                                          description: "Unexpected end while reading ||")
                }
                guard char == "|" else {
                    throw EvaluationError(kind: .unexpectedCharacter(reading: "|", expected: "|", got: char),
                                          description: "Unexpected character")
                }
                addToken(type: .operation(oper: OrOperator()), value: "||")

            case "?":
                guard let char = nextChar() else {
                    throw EvaluationError(kind: .unexpectedEnd(reading: "?"),
                                          description: "Unexpected end while reading ??")
                }
                guard char == "?" else {
                    throw EvaluationError(kind: .unexpectedCharacter(reading: "?", expected: "?", got: char),
                                          description: "Unexpected character")
                }
                addToken(type: .operation(oper: NilCoalescingOperator()), value: "??")
            case "\"":
                var cnt = ""
                var char = ""
                repeat {
                    guard let char1 = nextChar() else {
                        throw EvaluationError(kind: .unexpectedEnd(reading: "\""),
                                              description: "Unexpected end while reading string")
                    }
                    char = char1
                    cnt += char
                } while char != "\""
                cnt.remove(at: cnt.index(before: cnt.endIndex))
                addToken(type: .string, value: cnt)
            default:
                if isNumber(char: char) {
                    try parseNumber(char: char)
                } else if isChar(char: char) {
                    charBack()
                    try parseVariable()
                } else {
                    throw EvaluationError(kind: .unexpectedCharacter(reading: "",
                                                                     expected: "Number|Operand|Symbol",
                                                                     got: char))
                }
            }
        }
    }
}
// swiftlint:enable function_body_length

extension Evaluation {
    private func getPrecedence(token: Token) -> UInt8? {
        switch token.type {
        case .operation(oper: let oper):
            return oper.precedence
        case .open, .close, .bottom:
            return 10
        default:
            return nil
        }
    }

    private func makePostfix() throws {
        var res = [Token]()
        let stack = Stack<Token>()
        stack.push(item: Token(type: .bottom, value: "#"))

        for token in tokens {
            switch token.type {
            case .operation:
                // swiftlint:enable cyclomatic_complexity
                guard let top = stack.top(),
                    let currentPrecedence = getPrecedence(token: token),
                    let topPrecedence = getPrecedence(token: top) else {
                    throw EvaluationError(kind: .syntaxError, description: "Syntax error")
                }
                if currentPrecedence > topPrecedence {
                    stack.push(item: token)
                } else {
                    var tpPrecedence = topPrecedence
                    while currentPrecedence <= tpPrecedence {
                        res.append(stack.pop()!)
                        tpPrecedence = getPrecedence(token: stack.top()!)!
                    }
                    stack.push(item: token)
                }
            case .open:
                stack.push(item: token)
            case .close:
                while !stack.isEmpty() && stack.top()!.value != "(" {
                    res.append(stack.pop()!)
                }
                guard !stack.isEmpty() else {
                    throw EvaluationError(kind: .syntaxError, description: "Syntax error, missing (")
                }
                stack.pop()
            default:
                res.append(token)
            }
        }
        while stack.top()!.value != "#" {
            res.append(stack.pop()!)
        }
        _postfix = res
    }
}

extension Evaluation {
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

        for token in _postfix {
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
                        throw EvaluationError(
                            kind: .nilFound(expr: String(describing: first) + token.value + String(describing: second)))
                    }
                    stack.push(item: try binary(first!, second!))
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
                }
            case .bool:
                stack.push(item: token.value == "true")
            case .double:
                stack.push(item: Double(token.value)!)
            case .int:
                stack.push(item: Int(token.value)!)
            case .string:
                stack.push(item: token.value)
            case .stringCast:
                let eval = try Evaluation(expression: token.value)
                guard let res = try eval.evaluate(with: data) else {
                    throw EvaluationError(kind: .nilFound(expr: "\(token.value) as! String"))
                }
                stack.push(item: String(describing: res))
            case .intCast:
                let eval = try Evaluation(expression: token.value)
                guard let res = try eval.evaluate(with: data) else {
                    throw EvaluationError(kind: .nilFound(expr: "\(token.value) as! Int"))
                }
                if let a = res as? Double {
                    stack.push(item: Int(a))
                } else if let a = res as? UInt {
                    stack.push(item: Int(a))
                } else {
                    stack.push(item: Int(String(describing: res)))
                }
            case .uintCast:
                let eval = try Evaluation(expression: token.value)
                guard let res = try eval.evaluate(with: data) else {
                    throw EvaluationError(kind: .nilFound(expr: "\(token.value) as! UInt"))
                }
                if let a = res as? Double {
                    stack.push(item: UInt(a))
                } else if let a = res as? Int {
                    stack.push(item: UInt(a))
                } else {
                    stack.push(item: Int(String(describing: res)))
                }
            case .doubleCast:
                let eval = try Evaluation(expression: token.value)
                guard let res = try eval.evaluate(with: data) else {
                    throw EvaluationError(kind: .nilFound(expr: "\(token.value) as! Double"))
                }
                stack.push(item: Double(String(describing: res)))
            case .floatCast:
                let eval = try Evaluation(expression: token.value)
                guard let res = try eval.evaluate(with: data) else {
                    throw EvaluationError(kind: .nilFound(expr: "\(token.value) as! Float"))
                }
                stack.push(item: Float(String(describing: res)))
            case .boolCast:
                let eval = try Evaluation(expression: token.value)
                guard let res = try eval.evaluate(with: data) else {
                    throw EvaluationError(kind: .nilFound(expr: "\(token.value) as! Bool"))
                }
                stack.push(item: Bool(String(describing: res)))
            default:
                stack.push(item: getValue(name: token.value, from: data))
            }
        }
        guard !stack.isEmpty() else {
            throw EvaluationError(kind: .missingValue(forOperand: "result"), description: "There is no final result")
        }
        return stack.top()!
    }
}
