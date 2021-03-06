// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcode-version-manager",
    platforms: [.macOS(.v10_14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "xcvm",
            targets: ["XcodeVersionManager"]),
        .executable(
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
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "XcodeVersionManagerTests",
            dependencies: ["XcodeVersionManager"]),
    ]
)
