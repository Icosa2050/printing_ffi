// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "printing_ffi",
    platforms: [.macOS("10.15")],
    products: [
        .library(name: "printing-ffi", type: .dynamic, targets: ["printing_ffi"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "printing_ffi",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedLibrary("cups")
            ]
        )
    ]
)
