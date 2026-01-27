// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Lighthouse",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Lighthouse",
            path: "Lighthouse",
            exclude: ["Assets.xcassets", "Lighthouse.entitlements"]
        ),
    ]
)
