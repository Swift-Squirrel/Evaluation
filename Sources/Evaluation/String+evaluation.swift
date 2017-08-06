//
//  String+evaluation.swift
//  Evaluation
//
//  Created by Filip Klembara on 8/6/17.
//
//

public extension String {
    func evaluate(with data: [String: Any] = [:]) throws -> Any? {
        return try Evaluation(expression: self).evaluate(with: data)
    }

    func evaluateAsString(with data: [String: Any] = [:]) -> String? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? String
    }

    func evaluateAsBool(with data: [String: Any] = [:]) -> Bool? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? Bool
    }

    func evaluateAsInt(with data: [String: Any] = [:]) -> Int? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? Int
    }

    func evaluateAsUInt(with data: [String: Any] = [:]) -> UInt? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? UInt
    }

    func evaluateAsDouble(with data: [String: Any] = [:]) -> Double? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? Double
    }

    func evaluateAsFloat(with data: [String: Any] = [:]) -> Float? {
        guard let result = try? self.evaluate(with: data) else {
            return nil
        }
        return result as? Float
    }
}
