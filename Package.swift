// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcode-version-manager",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "XcodeVersionManager",
            targets: ["XcodeVersionManager"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "XcodeVersionManager",
            dependencies: []),
        .testTarget(
            name: "XcodeVersionManagerTests",
            dependencies: ["XcodeVersionManager"]),
    ]
)

//let package = Package(
//    name: "update-strings",
//    dependencies: [
//        .package(url: "https://github.com/kareman/SwiftShell.git", from: "4.0.0"),
//        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
//    ],
//    targets: [
//        .target(
//            name: "update-strings",
//            dependencies: [
//                "SwiftShell",
//                .product(name: "ArgumentParser", package: "swift-argument-parser"),
//            ]
//        ),
//    ]
//)
