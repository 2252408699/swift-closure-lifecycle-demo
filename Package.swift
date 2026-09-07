// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClosureLifecycleDemo",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "closure-lifecycle-demo", targets: ["ClosureLifecycleDemo"])
    ],
    targets: [
        .executableTarget(name: "ClosureLifecycleDemo")
    ]
)

