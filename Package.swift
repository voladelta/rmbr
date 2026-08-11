// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Memory",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Memory", targets: ["Memory"])
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/STTextView", from: "2.3.9")
    ],
    targets: [
        .executableTarget(
            name: "Memory",
            dependencies: [
                .product(name: "STTextView", package: "STTextView")
            ],
            path: "Sources/Memory",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MemoryTests",
            dependencies: ["Memory"],
            path: "Tests/MemoryTests"
        )
    ]
)
