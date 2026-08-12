// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TaqlynNavSwiftUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "TaqlynNavSwiftUI",
            targets: ["TaqlynNavSwiftUI"]
        ),
    ],
    targets: [
        .target(
            name: "TaqlynNavSwiftUI",
            path: "Sources/TaqlynNavSwiftUI"
        ),
        .testTarget(
            name: "TaqlynNavSwiftUITests",
            dependencies: ["TaqlynNavSwiftUI"],
            path: "Tests/TaqlynNavSwiftUITests"
        ),
    ]
)
