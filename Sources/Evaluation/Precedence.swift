//
//  Precedence.swift
//  Evaluation
//
//  Created by Filip Klembara on 8/5/17.
//
//

/// Operations
///
/// - binary: Binary operation
/// - binaryNilCoalescing: Nil coalescing operation `??`
/// - unary: Unary operation
/// - cast: Cast operation
public enum Operations {
    case binary(closure: (Any, Any) throws -> (Any))
    case binaryNilCoalescing(closure: (Any?, Any?) -> Any?)
    case unary(closure: (Any) throws -> (Any))
    case cast(closure: (Any) -> (Any?))
}

/// Associativity
///
/// - left: left
/// - right: right
public enum Associativity {
    case left
    case right
}

/// Operation
public protocol OperationProtocol {
    /// Precedence
    var precedence: UInt8 { get }

    /// Symbol
    var symbol: String { get }

    /// Operation
    var operation: Operations { get }

    /// Associativity
    var associativity: Associativity { get }
}

struct AdditionOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "+"

    let precedence: UInt8 = 140

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst + scnd
        case let (frst, scnd) as (Double, Double):
            return frst + scnd
        case let (frst, scnd) as (String, String):
            return frst + scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst + scnd
        case let (frst, scnd) as (Float, Float):
            return frst + scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "+",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}

struct SubOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "-"

    let precedence: UInt8 = 140

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst - scnd
        case let (frst, scnd) as (Double, Double):
            return frst - scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst - scnd
        case let (frst, scnd) as (Float, Float):
            return frst - scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "-",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}

struct MulOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "*"

    let precedence: UInt8 = 150

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst * scnd
        case let (frst, scnd) as (Double, Double):
            return frst * scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst * scnd
        case let (frst, scnd) as (Float, Float):
            return frst * scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "*",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}

struct DivOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "/"

    let precedence: UInt8 = 150

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst / scnd
        case let (frst, scnd) as (Double, Double):
            return frst / scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst / scnd
        case let (frst, scnd) as (Float, Float):
            return frst / scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "/",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}

struct ModOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "%"

    let precedence: UInt8 = 150

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst % scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst % scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "%",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}

struct EqualOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "=="

    let precedence: UInt8 = 130

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst == scnd
        case let (frst, scnd) as (Double, Double):
            return frst == scnd
        case let (frst, scnd) as (String, String):
            return frst == scnd
        case let (frst, scnd) as (Bool, Bool):
            return frst == scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst == scnd
        case let (frst, scnd) as (Float, Float):
            return frst == scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "==",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}

struct NotEqualOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "!="

    let precedence: UInt8 = 130

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst != scnd
        case let (frst, scnd) as (Double, Double):
            return frst != scnd
        case let (frst, scnd) as (String, String):
            return frst != scnd
        case let (frst, scnd) as (Bool, Bool):
            return frst != scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst != scnd
        case let (frst, scnd) as (Float, Float):
            return frst != scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "!=",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}


struct LessOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "<"

    let precedence: UInt8 = 130

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst < scnd
        case let (frst, scnd) as (Double, Double):
            return frst < scnd
        case let (frst, scnd) as (String, String):
            return frst < scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst < scnd
        case let (frst, scnd) as (Float, Float):
            return frst < scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "<",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}

struct LessEqualOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "<="

    let precedence: UInt8 = 130

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst <= scnd
        case let (frst, scnd) as (Double, Double):
            return frst <= scnd
        case let (frst, scnd) as (String, String):
            return frst <= scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst <= scnd
        case let (frst, scnd) as (Float, Float):
            return frst <= scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "<=",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}


struct GreaterOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = ">"

    let precedence: UInt8 = 130

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst > scnd
        case let (frst, scnd) as (Double, Double):
            return frst > scnd
        case let (frst, scnd) as (String, String):
            return frst > scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst > scnd
        case let (frst, scnd) as (Float, Float):
            return frst > scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: ">",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}
struct GreaterEqualOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = ">="

    let precedence: UInt8 = 130

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Int, Int):
            return frst >= scnd
        case let (frst, scnd) as (Double, Double):
            return frst >= scnd
        case let (frst, scnd) as (String, String):
            return frst >= scnd
        case let (frst, scnd) as (UInt, UInt):
            return frst >= scnd
        case let (frst, scnd) as (Float, Float):
            return frst >= scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: ">=",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}


struct AndOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "&&"

    let precedence: UInt8 = 120

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Bool, Bool):
            return frst && scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "&&",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}

struct OrOperator: OperationProtocol {
    let associativity: Associativity = .left

    let symbol = "||"

    let precedence: UInt8 = 110

    let operation: Operations = .binary() {
        (first, second) in
        switch (first, second) {
        case let (frst, scnd) as (Bool, Bool):
            return frst || scnd
        default:
            throw EvaluationError(
                kind: .canNotApplyBinOperand(
                    oper: "||",
                    type1: String(describing: type(of: first)),
                    type2: String(describing: type(of: second))
                )
            )
        }
    }
}

struct NotOperator: OperationProtocol {
    let associativity: Associativity = .right

    let symbol = "!"

    let precedence: UInt8 = 200

    let operation: Operations = .unary() {
        (operand) in
        guard let oper  = operand as? Bool else {
            throw EvaluationError(
                kind: .canNotApplyUnaryOperand(
                    oper: "!",
                    type: String(describing: type(of: operand))
                )
            )
        }
        return !oper
    }
}

struct NilCoalescingOperator: OperationProtocol {
    let associativity: Associativity = .right

    let symbol = "??"

    let precedence: UInt8 = 131

    let operation: Operations = .binaryNilCoalescing() {
        (first, second) in
        return first ?? second
    }
}

struct StringCast: OperationProtocol {
    let associativity: Associativity = .right

    let symbol = "String"

    let precedence: UInt8 = 210

    let operation: Operations = .cast { (string) -> (Any?) in
        return String(describing: string)
    }
}

struct IntCast: OperationProtocol {
    let associativity: Associativity = .right

    let symbol = "Int"

    let precedence: UInt8 = 210

    let operation: Operations = .cast { (value) -> (Any?) in
        if let double = value as? Double {
            return Int(double)
        } else if let uint = value as? UInt {
            return Int(uint)
        } else {
            return Int(String(describing: value))
        }
    }
}

struct UIntCast: OperationProtocol {
    let associativity: Associativity = .right

    let symbol = "UInt"

    let precedence: UInt8 = 210

    let operation: Operations = .cast { (value) -> (Any?) in
        if let double = value as? Double {
            return UInt(double)
        } else if let int = value as? Int {
            return UInt(int)
        } else {
            return UInt(String(describing: value))
        }
    }
}

struct DoubleCast: OperationProtocol {
    let associativity: Associativity = .right

    let symbol = "Double"

    let precedence: UInt8 = 210

    let operation: Operations = .cast { (value) -> (Any?) in
        return Double(String(describing: value))
    }
}

struct FloatCast: OperationProtocol {
    let associativity: Associativity = .right

    let symbol = "Float"

    let precedence: UInt8 = 210

    let operation: Operations = .cast { (value) -> (Any?) in
        return Float(String(describing: value))
    }
}

struct BoolCast: OperationProtocol {
    let associativity: Associativity = .right

    let symbol = "Bool"

    let precedence: UInt8 = 210

    let operation: Operations = .cast { (value) -> (Any?) in
        return Bool(String(describing: value))
    }
}
