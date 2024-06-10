// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "network",
    platforms: [
		.macOS(.v10_15),
		.iOS(.v13),
		.watchOS(.v6),
		.tvOS(.v13),
    ],
    products: [
        .library(name: "Network", targets: ["Network"]),
    ],
    dependencies: [
		.package(url: "https://github.com/ViktorChernykh/key-chaining.git", from: "1.1.0"),
		.package(url: "https://github.com/ViktorChernykh/fullerror-model.git", from: "1.0.0"),
	],
    targets: [
        .target(name: "Network", dependencies: [
			.product(name: "KeyChaining", package: "key-chaining"),
			.product(name: "FullErrorModel", package: "fullerror-model"),
		]),
        .testTarget(name: "NetworkTests", dependencies: ["Network"]),
    ]
)
