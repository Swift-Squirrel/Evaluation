import XCTest
@testable import EvaluationTests

XCTMain([
    testCase(InfixEvaluationTests.allTests),
    testCase(PostfixEvaluationTests.allTests),
])
