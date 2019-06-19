// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Coverage",
    platforms: [
           .macOS(.v10_13),
    ],
    products: [
        .executable(name: "coverage", targets: ["Coverage"]),
        ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Runner.git", from: "1.0.2"),
        .package(url: "https://github.com/elegantchaos/Arguments.git", from: "1.1.0"),
        .package(url: "https://github.com/elegantchaos/Logger.git", from: "1.3.6"),
    ],
    targets: [
        .target(
            name: "Coverage",
            dependencies: ["Runner", "Arguments", "Logger"]),
        .testTarget(
            name: "CoverageTests",
            dependencies: ["Coverage"]),
    ]
)
