// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "XTerm",
    platforms: [.macOS(.v26)],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm", from: "1.9.0"),
    ],
    targets: [
        .executableTarget(name: "XTerm", dependencies: ["SwiftTerm"]),
    ]
)
