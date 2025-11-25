// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthFeature",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AuthFeature",
            targets: ["AuthFeature"]
        ),
    ],
    targets: [
        .target(
            name: "AuthFeature"
        ),
        .testTarget(
            name: "AuthFeatureTests",
            dependencies: ["AuthFeature"]
        ),
    ]
)
