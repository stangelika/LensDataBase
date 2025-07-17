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
        )
    ],
    dependencies: [
        // Add any external dependencies here if needed
    ],
    targets: [
        .target(
            name: "LensDataBase",
            path: ".",
            exclude: [
                "Tests",
                ".github",
                ".git",
                ".gitignore",
                ".swiftlint.yml",
                "README.md",
                "CHANGELOG.md",
                "CONTRIBUTING.md",
                "LICENSE",
                "Assets.xcassets",
                ".swiftpm"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        .testTarget(
            name: "LensDataBaseTests",
            dependencies: ["LensDataBase"],
            path: "Tests/LensDataBaseTests"
        )
    ]
)