// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LensDataBase",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "LensDataBase",
            targets: ["AppModule"]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            exclude: ["README.md"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)
