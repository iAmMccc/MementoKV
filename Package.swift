// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MementoKV",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MementoKV",
            targets: ["MementoKV"]
        ),
    ],
    dependencies: [
        // FMDB 的 SPM 依赖（它在 GitHub 上有官方支持）
        .package(url: "https://github.com/ccgus/fmdb.git", from: "2.7.9")
    ],
    targets: [
        .target(
            name: "MementoKV",
            dependencies: [
                .product(name: "FMDB", package: "fmdb")
            ],
            path: "MementoKV/Classes",
            exclude: [],
            resources: []
        ),
        .testTarget(
            name: "MementoKVTests",
            dependencies: ["MementoKV"],
            path: "MementoKV/Tests"
        )
    ]
)
