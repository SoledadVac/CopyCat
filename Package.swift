// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CopyCat",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "CopyCat",
            targets: ["CopyCat"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.0")
    ],
    targets: [
        .executableTarget(
            name: "CopyCat",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ]
        ),
        .testTarget(
            name: "CopyCatTests",
            dependencies: ["CopyCat"]
        )
    ]
)
