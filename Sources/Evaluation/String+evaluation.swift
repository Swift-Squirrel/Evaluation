//
//  String+evaluation.swift
//  Evaluation
//
//  Created by Filip Klembara on 8/6/17.
//
//

@available(*, unavailable, renamed: "InfixEvaluation")
public typealias Evaluation = InfixEvaluation

// MARK: - Evaluate functions
public extension String {
    /// Evaluate self
    ///
    /// - Parameter data: Data
    /// - Returns: Result of evaluation
    /// - Throws: Evaluation errors
    func evaluate(with data: [String: Any] = [:]) throws -> Any? {
        return try InfixEvaluation(expression: self).evaluate(with: data)
    }

    /// Evaluate self and expect result to be String
    ///
    /// - Parameter data: Data
    /// - Returns: Result of evaluation, nil in case of error
    func evaluateAsString(with data: [String: Any] = [:]) -> String? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? String
    }

    /// Evaluate self and expect result to be Bool
    ///
    /// - Parameter data: Data
    /// - Returns: Result of evaluation, nil in case of error
    func evaluateAsBool(with data: [String: Any] = [:]) -> Bool? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? Bool
    }

    /// Evaluate self and expect result to be Int
    ///
    /// - Parameter data: Data
    /// - Returns: Result of evaluation, nil in case of error
    func evaluateAsInt(with data: [String: Any] = [:]) -> Int? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? Int
    }

    /// Evaluate self and expect result to be UInt
    ///
    /// - Parameter data: Data
    /// - Returns: Result of evaluation, nil in case of error
    func evaluateAsUInt(with data: [String: Any] = [:]) -> UInt? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? UInt
    }

    /// Evaluate self and expect result to be Double
    ///
    /// - Parameter data: Data
    /// - Returns: Result of evaluation, nil in case of error
    func evaluateAsDouble(with data: [String: Any] = [:]) -> Double? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? Double
    }

    /// Evaluate self and expect result to be Float
    ///
    /// - Parameter data: Data
    /// - Returns: Result of evaluation, nil in case of error
    func evaluateAsFloat(with data: [String: Any] = [:]) -> Float? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? Float
    }
}
