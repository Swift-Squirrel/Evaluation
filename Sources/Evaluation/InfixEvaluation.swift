//
//  InfixEvaluation.swift
//  Evaluation
//
//  Created by Filip Klembara on 8/5/17.
//
//

/// InfixEvaluation class
public class InfixEvaluation: PostfixEvaluation {
    private var tokens = [Token]()
    private let string: String
    private let chars: [String]

    /// Perform lexical analysis and makes postfix notation of given expression
    ///
    /// - Parameter string: expression
    /// - Throws: lexical and syntax error as `EvaluationError`
    public init(expression string: String) throws {
        self.string = string
        self.chars = string.map({ $0.description })
        super.init(postfix: [])
        try parseTokens(string: string)
        self.postfix = try makePostfix()
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
                guard isChar(char: char) || char == "_" else {
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
                charBack()
                addToken(type: .operation(oper: StringCast()), value: "String")
            } else {
                fallthrough
            }
        case "Int":
            if let char = nextChar(), char == "(" {
                charBack()
                addToken(type: .operation(oper: IntCast()), value: "Int")
            } else {
                fallthrough
            }
        case "UInt":
            if let char = nextChar(), char == "(" {
                charBack()
                addToken(type: .operation(oper: UIntCast()), value: "UInt")
            } else {
                fallthrough
            }
        case "Bool":
            if let char = nextChar(), char == "(" {
                charBack()
                addToken(type: .operation(oper: BoolCast()), value: "Bool")
            } else {
                fallthrough
            }
        case "Double":
            if let char = nextChar(), char == "(" {
                charBack()
                addToken(type: .operation(oper: DoubleCast()), value: "Double")
            } else {
                fallthrough
            }
        case "Float":
            if let char = nextChar(), char == "(" {
                charBack()
                addToken(type: .operation(oper: FloatCast()), value: "Float")
            } else {
                fallthrough
            }
        case "_":
            throw EvaluationError(kind: .unexpectedCharacter(reading: cnt, expected: "Variable identifier", got: "\(nextChar() ?? "EOF")"), description: "Variable name can not be just '_'")
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

extension InfixEvaluation {

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
                    if char1 == "\\" {
                        guard let char2 = nextChar() else {
                            throw EvaluationError(kind: .unexpectedEnd(reading: "escape sequence"),
                                                  description: "Unexpected end while reading string")
                        }
                        let escapedChar: String
                        switch char2 {
                        case "0":
                            escapedChar = "\0"
                        case "\\", "\'", "\"":
                            escapedChar = char2
                        case "t":
                            escapedChar = "\t"
                        case "n":
                            escapedChar = "\n"
                        case "r":
                            escapedChar = "\r"
                        default:
                            throw EvaluationError(kind: .unexpectedCharacter(reading: "\\", expected: "0|\\|t|n|r|\"|\'", got: char2))
                        }
                        char = char1
                        cnt += escapedChar
                    } else {
                        char = char1
                        cnt += char
                    }
                } while char != "\""
                let _ = cnt.removeLast()
                addToken(type: .string, value: cnt)
            default:
                if isNumber(char: char) {
                    try parseNumber(char: char)
                } else if isChar(char: char) || char == "_" {
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

extension InfixEvaluation {
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

    private func makePostfix() throws -> [PostfixEvaluation.Token] {
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
        return res
    }
}
