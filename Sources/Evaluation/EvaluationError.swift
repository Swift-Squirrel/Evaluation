//
//  EvaluationError.swift
//  Evaluation
//
//  Created by Filip Klembara on 8/5/17.
//
//

public struct EvaluationError: Error, CustomStringConvertible {
    public enum ErrorKind {
        case canNotApplyBinOperand(oper: String, type1: String, type2: String)
        case canNotApplyUnaryOperand(oper: String, type: String)
        case unexpectedEnd(reading: String)
        case unexpectedCharacter(reading: String, expected: String, got: String)
        case syntaxError
        case missingValue(forOperand: String)
        case nilFound(expr: String)
    }

    init(kind: ErrorKind, description: String? = nil) {
        self.kind = kind
        _description = description
    }

    private let _description: String?

    /// Error kind
    public let kind: ErrorKind

    /// A textual representation of error
    public var description: String {
        if let desc = _description {
            return desc
        }
        switch kind {
        case .canNotApplyUnaryOperand(let oper, let type):
            return "Can not apply '\(oper)' at \(type)"
        case .canNotApplyBinOperand(let oper, let type1, let type2):
            return "Can not apply '\(oper)' at \(type1) \(oper) \(type2)"
        case .unexpectedEnd(let reading):
            return "Unexpected end while reading: '\(reading)'"
        case .unexpectedCharacter(let reading, let expected, let got):
            return "Unexpected character while reading '\(reading)', expected '\(expected)' but got '\(got)'"
        case .syntaxError:
            return "Syntax error"
        case .missingValue(let operand):
            return "Missing value for '\(operand)'"
        case .nilFound:
            return "Found nil"
        }
    }
}
