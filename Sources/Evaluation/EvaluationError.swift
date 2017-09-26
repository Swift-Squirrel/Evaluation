//
//  EvaluationError.swift
//  Evaluation
//
//  Created by Filip Klembara on 8/5/17.
//
//

/// Error structure
public struct EvaluationError: Error, CustomStringConvertible {
    /// Error kind
    ///
    /// - canNotApplyBinOperand: Can not apply binary operand
    /// - canNotApplyUnaryOperand: Can not apply unary operand
    /// - unexpectedEnd: Unexpected end of string
    /// - unexpectedCharacter: Unexpected character
    /// - syntaxError: Syntax error
    /// - missingValue: Missing value for operand
    /// - nilFound: Unexpected nil found
    /// - decodingError: Error while decoding postfix in `PostfixEvaluation(postfix:)`
    /// - encodingError: Error while encoding postfix
    /// - unknownOperation: Unknown operation symbol in encoding
    public enum ErrorKind {
        case canNotApplyBinOperand(oper: String, type1: String, type2: String)
        case canNotApplyUnaryOperand(oper: String, type: String)
        case unexpectedEnd(reading: String)
        case unexpectedCharacter(reading: String, expected: String, got: String)
        case syntaxError
        case missingValue(forOperand: String)
        case nilFound(expr: String)
        case decodingError
        case encodingError
        case unknownOperation(operation: String)
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
        case .decodingError:
            return "Error while decoding postfix in PostfixEvaluation(postfix:)"
        case .encodingError:
            return "Trying encode postfix with invalid token"
        case .unknownOperation(let symbol):
            return "Unknown operation symbol '\(symbol)' found while encoding"
        }
    }
}
