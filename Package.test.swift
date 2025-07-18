// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LensDataBase",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "LensDataBase",
            targets: ["LensDataBase"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "LensDataBase",
            dependencies: [],
            path: "Sources/LensDataBase",
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "LensDataBaseTests",
            dependencies: ["LensDataBase"],
            path: "Tests/LensDataBaseTests"
        ),
    ]
)