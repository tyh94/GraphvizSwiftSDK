// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphvizSDK",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GraphvizSDK",
            targets: ["GraphvizSDK", "CGraphvizSDK"]
        ),
    ],
    targets: [
        .target(name: "CGraphvizSDK"),
        .target(
            name: "GraphvizSDK",
            dependencies: ["CGraphvizSDK"]
        ),
        .testTarget(
            name: "GraphvizSDKTests",
            dependencies: ["GraphvizSDK"]
        ),
    ]
)
