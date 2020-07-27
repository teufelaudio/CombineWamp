// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "CombineWamp",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)],
    products: [
        .library(name: "CombineWamp", targets: ["CombineWamp"])
    ],
    dependencies: [
        .package(url: "https://github.com/teufelaudio/CombineWebSocket", .branch("master")),
        .package(url: "https://github.com/CombineCommunity/CombineExt", from: "1.2.0"),
        .package(url: "https://github.com/teufelaudio/FoundationExtensions", .branch("master"))
    ],
    targets: [
        .target(name: "CombineWamp", dependencies: ["CombineWebSocket", "CombineExt", "FoundationExtensions"]),
        .testTarget(name: "CombineWampTests", dependencies: ["CombineWamp"])
    ]
)
