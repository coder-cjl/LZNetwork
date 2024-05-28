// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "LZNetwork",
    platforms: [
        .iOS(.v13),
        .watchOS(.v6),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "LZNetwork",
            targets: ["LZNetwork"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.3")),
    ],
    targets: [
        .target(
            name: "LZNetwork",
            dependencies: ["Alamofire", "Moya"],
            path: "Source"
        ),
        .testTarget(
            name: "LZNetworkTests",
            dependencies: ["LZNetwork"]),
    ],
    swiftLanguageVersions: [.v5]
)

