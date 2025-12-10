// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetTrace",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "NetTrace",
            targets: ["NetTrace"]
        ),
    ],
    targets: [
        .target(
            name: "NetTrace",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
    ]
)
