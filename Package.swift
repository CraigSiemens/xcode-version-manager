// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcode-version-manager",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "xcvm",
            targets: ["XcodeVersionManager"]
        ),
        .library(
            name: "TableKit",
            targets: ["TableKit"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/craigsiemens/swift-argument-parser",
            branch: "zsh-completion-option-group-646"
        ),
        .package(
            url: "https://github.com/saagarjha/unxip",
            from: "3.0.0"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "XcodeVersionManager",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "TableKit"),
                .target(name: "Unxip")
            ]
        ),
        
        .target(
            name: "TableKit"
        ),
        .testTarget(
            name: "TableKitTests",
            dependencies: ["TableKit"]
        ),
        .target(
            name: "Unxip",
            dependencies: [
                .product(name: "libunxip", package: "unxip"),
            ]
        )
    ]
)
