// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "LensDataBase-Refactored",
    platforms: [
        .iOS("17.0") // Using iOS 17+ for @Observable and modern Swift features
    ],
    products: [
        .iOSApplication(
            name: "LensDataBase-Refactored",
            targets: ["AppModule"],
            bundleIdentifier: "com.lensdatabase.refactored.app",
            teamIdentifier: "K28W7HPGF3",
            displayVersion: "8.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
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