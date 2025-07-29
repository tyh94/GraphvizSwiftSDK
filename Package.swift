// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphvizSDK",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "GraphvizSDK",
            type: .static,
            targets: ["GraphvizSDK"]
        ),
        .library(
            name: "CGraphvizSDK",
            type: .static,
            targets: ["CGraphvizSDK"]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:tyh94/SnapshotsKit.git", from: "1.0.0"),
    ],
    targets: [
        // C/C++ Target
        .target(
            name: "CGraphvizSDK",
            path: "Sources/CGraphvizSDK",
            sources: ["src"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"), // Путь к заголовкам
                .unsafeFlags(["-Wno-deprecated-declarations"]), // При необходимости
            ],
            cxxSettings: [
                .headerSearchPath("include"),
            ]
        ),

        .target(
            name: "GraphvizSDK",
            dependencies: ["CGraphvizSDK"],
            path: "Sources/GraphvizSDK"
        ),
        .testTarget(
            name: "GraphvizSDKTests",
            dependencies: [
                "GraphvizSDK",
                .product(name: "SnapshotsKit", package: "SnapshotsKit")
            ]
        )
    ]
)
