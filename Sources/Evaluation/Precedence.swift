//
//  Precedence.swift
//  Evaluation
//
//  Created by Filip Klembara on 8/5/17.
//
//

enum Operations {
    case binary(closure: (Any, Any) throws -> (Any))
    case binaryNilCoalescing(closure: (Any?, Any?) -> Any?)
    case unary(closure: (Any) throws -> (Any))
}
enum Associativity {
    case left
    case right
}

protocol OperationProtocol {
    var precedence: UInt8 { get }

    var symbol: String { get }

    var operation: Operations { get }

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
        (op) in
        guard let oper  = op as? Bool else {
            throw EvaluationError(
                kind: .canNotApplyUnaryOperand(
                    oper: "!",
                    type: String(describing: type(of: op))
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
