// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WhiskrImageSPM",
    platforms: [
        .iOS(.v17),
//        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WhiskrImageSPM",
            targets: ["WhiskrImageSPM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", exact: "2.4.5"),
//        .package(path: "../SQAUtility"),
//        .package(path: "../SQAServices")
    ],
    targets: [
        .target(
            name: "WhiskrImageSPM",
            dependencies: [
                .product(name: "Factory", package: "Factory"),
//                "SQAUtility",
//                "SQAServices"
            ]
        ),
        .testTarget(
            name: "WhiskrImageSPMTests",
            dependencies: ["WhiskrImageSPM"]
        ),
    ]
)
