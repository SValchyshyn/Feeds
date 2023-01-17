// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Feeds",
	platforms: [
		.iOS(.v13)
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "Feeds",
			targets: ["Feeds"]),
        .library(
            name: "Receipts",
            targets: ["Receipts"]),
		.library(
			name: "CustomerFeedback",
			targets: ["CustomerFeedback"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
//		.package(url: "https://github.com/apple/swift-log", exact: "1.4.4"),
		.package(url: "https://github.com/SValchyshyn/Core", from: "0.0.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "Feeds",
			dependencies: [
				.product(name: "Authentication", package: "Core"),
				.product(name: "Core", package: "Core"),
				.product(name: "Stores", package: "Core"),
				"Receipts",
				"CustomerFeedback"
			],
			path: "Sources/Feeds/Feeds",
			resources: [
				.process("Resources")
			]),
        .target(
            name: "Receipts",
            dependencies: [
				.product(name: "Authentication", package: "Core"),
				.product(name: "Core", package: "Core"),
			],
			path: "Sources/Receipts/Receipts",
			resources: [
				.process("Resources")
			]),
		.target(
			name: "CustomerFeedback",
			dependencies: [
				.product(name: "Authentication", package: "Core"),
				.product(name: "Core", package: "Core"),
			],
			path: "Sources/CustomerFeedback/CustomerFeedback",
			resources: [
				.process("Resources")
			]),
    ]
)
