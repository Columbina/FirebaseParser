// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseParser",
    products: [
        .library(
            name: "FirebaseParser",
            targets: ["FirebaseParser"]),
    ],
    targets: [
        .target(
            name: "FirebaseParser",
            dependencies: []),
        .testTarget(
            name: "FirebaseParserTests",
            dependencies: ["FirebaseParser"]),
    ]
)
