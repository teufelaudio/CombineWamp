// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "CombineWamp",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(name: "CombineWamp", targets: ["CombineWamp"]),
        .library(name: "CombineWampDynamic", type: .dynamic, targets: ["CombineWamp"])
    ],
    dependencies: [
        .package(url: "https://github.com/teufelaudio/CombineWebSocket.git", .upToNextMajor(from: "0.1.1")),
        .package(url: "https://github.com/teufelaudio/FoundationExtensions.git", .upToNextMajor(from: "0.2.0"))
    ],
    targets: [
        .target(
            name: "CombineWamp",
            dependencies: [
                "CombineWebSocket",
                .product(name: "FoundationExtensions", package: "FoundationExtensions")
            ]
        ),
        .target(
            name: "CombineWampDynamic",
            dependencies: [
                "CombineWebSocket",
                .product(name: "FoundationExtensionsDynamic", package: "FoundationExtensions")
            ]
        ),
        .testTarget(name: "CombineWampTests", dependencies: ["CombineWamp"]),
        .testTarget(name: "CombineWampIntegrationTests", dependencies: ["CombineWamp"])
    ]
)
