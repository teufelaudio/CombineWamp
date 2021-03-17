// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "CombineWamp",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(name: "CombineWamp", targets: ["CombineWamp"])
    ],
    dependencies: [
        .package(url: "https://github.com/teufelaudio/CombineWebSocket.git", .branch("master")),
        .package(url: "https://github.com/teufelaudio/FoundationExtensions.git", .upToNextMajor(from: "0.1.4"))
    ],
    targets: [
        .target(
            name: "CombineWamp",
            dependencies: [
                "CombineWebSocket",
                .product(name: "FoundationExtensions", package: "FoundationExtensions")
            ]
        ),
        .testTarget(name: "CombineWampTests", dependencies: ["CombineWamp"]),
        .testTarget(name: "CombineWampIntegrationTests", dependencies: ["CombineWamp"])
    ]
)
