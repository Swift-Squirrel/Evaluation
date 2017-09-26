// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Evaluation",
    products: [
        .library(
            name: "Evaluation",
            targets: ["Evaluation"]),
        ],
    targets: [
        .target(
            name: "Evaluation"),
        .testTarget(
            name: "EvaluationTests",
            dependencies: ["Evaluation"]),
        ]
)
