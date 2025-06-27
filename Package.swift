// swift-tools-version: 5.7
// this_file: Package.swift

import PackageDescription

let package = Package(
    name: "macdefaultbrowser",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "macdefaultbrowser",
            targets: ["macdefaultbrowser"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "macdefaultbrowser",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        ),
        .testTarget(
            name: "macdefaultbrowserTests",
            dependencies: ["macdefaultbrowser"]
        )
    ]
)