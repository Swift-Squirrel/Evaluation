# Evaluation

Evaluation is swift library which can evaluate content of String and return result or postfix notation. This library is runnable on Linux too :)

- [Operations](#operations)
- [Casting functions](#casting-functions)
- [Usage](#usage)
    - [PostfixEvaluation class](#postfixevaluation-class)
    - [InfixEvaluation class](#infixevaluation-class)
    - [String extension](#string-extension)
    - [Using variables](#using-variables)
    - [Array functions](#array-functions)
- [Examples](#examples)
- [Errors](#errors)
- [Installation](#installation)
    

## Operations
Operands must be same type

|Operation|Precedence|Type|Operands type|
|:--:|:--:|:--:|:--|
|`!`|200|Unary| `Bool` |
|`*`|150|Binary| `Int`, `UInt`, `Double`, `Float` |
|`/`|150|Binary| `Int`, `UInt`, `Double`, `Float` |
|`%`|150|Binary| `Int`, `UInt`|
|`+`|140|Binary| `Int`, `UInt`, `Double`, `Float`, `String` |
|`-`|140|Binary| `Int`, `UInt`, `Double`, `Float` |
|`??`|131|Binary| `Any?` |
|`==`|130|Binary| `Int`, `UInt`, `Double`, `Float`, `String`, `Bool`, `nil` |
|`!=`|130|Binary| `Int`, `UInt`, `Double`, `Float`, `String`, `Bool`, `nil` |
|`<`|130|Binary| `Int`, `UInt`, `Double`, `Float`, `String` |
|`<=`|130|Binary| `Int`, `UInt`, `Double`, `Float`, `String` |
|`>`|130|Binary| `Int`, `UInt`, `Double`, `Float`, `String` |
|`>=`|130|Binary| `Int`, `UInt`, `Double`, `Float`, `String` |
|`&&`|120|Binary| `Bool` |
|`\|\|`|110|Binary| `Bool` |

## Casting functions
You can cast with theese functions:

```swift
String(_) -> String
Double(_) -> Double?
Float(_) -> Float?
Int(_) -> Int?
UInt(_) -> UInt?
Bool(_) -> Bool?
```

## Usage

You can use evaluations with String extension or with `Evaluation` class just don't forget to import library

```swift
import Evaluation
```

### PostfixEvaluation class
This class gives you power to evaluate from postfix tokens.

```swift
public class PostfixEvaluation {
    /// Serialized postfix in JSON format
    public func serializedPostfix() throws -> Data
    public func serializedPostfix() throws -> String
    public var postfix: [PostfixEvaluation.Token] { get }
    
    /// Construct from JSON
    public init(postfix: [PostfixEvaluation.Token])
    public init(postfix: String) throws 
    public init(postfixData: Data) throws
    
    /// Evaluate
    public func evaluate(with data: [String: Any] = [:]) throws -> Any?
}
```

### InfixEvaluation class
InfixEvaluation class divide proccess to two parts, first token parsing and postfix transformation and second evaluates expression.

```swift
public class InfixEvaluation: PostfixEvaluation {
    /// Serialized postfix in JSON format
    public func serializedPostfix() throws -> Data
    public func serializedPostfix() throws -> String
    
    /// Perform lexical analysis and makes postfix notation of given expression
    ///
    /// - Parameter string: expression
    /// - Throws: lexical and syntax error as `EvaluationError`
    public init(expression string: String) throws
    
    /// Evaluate expression and return result
    ///
    /// - Parameter data: Dictionary with variables used in expression
    /// - Returns: result of expression
    /// - Throws: EvaluationError 
    public func evaluate(with data: [String : Any] = default) throws -> Any?
}
```

### String extension
We add string extenstion so all you need to write is:

```swift
try "1+5".evaluate() as! Int // 6

"1+5".evaluateAsInt()! // 6
```

#### extension

```swift
public extension String {

    public func evaluate(with data: [String : Any] = default) throws -> Any?

    public func evaluateAsString(with data: [String : Any] = default) -> String?

    public func evaluateAsBool(with data: [String : Any] = default) -> Bool?

    public func evaluateAsInt(with data: [String : Any] = default) -> Int?

    public func evaluateAsUInt(with data: [String : Any] = default) -> UInt?

    public func evaluateAsDouble(with data: [String : Any] = default) -> Double?

    public func evaluateAsFloat(with data: [String : Any] = default) -> Float?
}
```

### Using variables
You can use variables in evaluation if you pass `[String: Any]` to `evaluate(with:)` then you can access them with dot notation

```swift
let data: [String: Any] = [
    "name": "John",
    "sleeps": 8  
]

// John is awake 16 hours per day
"name + \" is awake \" + String(24 - sleeps) + \" hours per day\"".evaluateAsString(with: data)!
```

### Array function
If you are sure about variable type ([Any] or [String: Any]) you can use `.count` to get number of elements

```swift
let data: [String: Any] = [
    "numbers": [1, 2 ,3 , 4]
]

"numbers.count".evaluateAsInt(with: data)! // 4
```

## Examples

```swift
import Evaluation

// If you wan to know if something goes wrong use Evaluation class
do {
    let eval = try InfixEvaluation(expression: "1 + 5 < seven")
    if let result = (try eval.evaluate(with: ["seven": 7])) as? Bool {
        print(result) // true
    }
} catch let error {
    print(error)
}

// when you are interested only in result you can use extension
print("1 + 5".evaluateAsInt()!) // 6
let data = [
    "person1": [
        "name": "Matt",
        "age": 21,
        "male": true,
        "children": [
            "Ann",
            "Matt Jr."
        ]
    ],
    "person2": [
        "name": "Miriam",
        "age": 19,
        "male": false,
        "children": [String]()
    ]
]

print("person1.name != person2.name".evaluateAsBool(with: data)!) // true

print("person1.children.count == person2.children.count".evaluateAsBool(with: data)!)   // false

// You can change type like this
print("Int( (Double(person1.age) + Double(person2.age)) / 2.0 )".evaluateAsInt(with: data)!) // 20

// JSON usage
do {
    let infixEval = try InfixEvaluation(expression: "3 + 1")
    let postfix: String = try infixEval.serializedPostfix()
    print(postfix) // [{"type":{"int":"Int"},"value":"3"},{"type":{"int":"Int"},"value":"1"},{"type":{"operation":"+"},"value":"+"}]
    let postfixEval = try PostfixEvaluation(postfix: postfix)
    let result = try postfixEval.evaluate() as! Int
    print(result) // 4
} catch let error {
    print(error)
}
```

## Errors
If something goes wrong Evaluation throw `EvaluationError` struct with attributes `kind` and `description`

```swift
public struct EvaluationError: Error, CustomStringConvertible {

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
    
    /// Error kind
    public let kind: ErrorKind

    /// A textual representation of this instance.
    public var description: String { get }
}
```
## Installation

### Package Manager

You can add this to Package.swift

```swift
dependencies: [
	.package(url: "https://github.com/Swift-Squirrel/Evaluation.git", from: "0.3.1")
]
```
