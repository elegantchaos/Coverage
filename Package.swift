// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Coverage",
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Runner.git", from: "1.0.1"),
        .package(url: "https://github.com/elegantchaos/Arguments.git", from: "1.0.4"),
    ],
    targets: [
        .target(
            name: "Coverage",
            dependencies: ["Runner", "Arguments"]),
        .testTarget(
            name: "CoverageTests",
            dependencies: ["Coverage"]),
    ]
)
