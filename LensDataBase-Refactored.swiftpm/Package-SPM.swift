// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LensDataBase-Refactored",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LensDataBase-Refactored",
            targets: ["LensDataBase-Refactored"]
        )
    ],
    targets: [
        .target(
            name: "LensDataBase-Refactored",
            path: ".",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)