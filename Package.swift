// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpellChecker",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SpellChecker",
            targets: ["SpellChecker"]),
    ],
    dependencies: [
        .package(name: "MorphologicalAnalysis", url: "https://github.com/StarlangSoftware/TurkishMorphologicalAnalysis-Swift.git", .exact("1.0.7")),         .package(name: "NGram", url: "https://github.com/StarlangSoftware/NGram-Swift.git", .exact("1.0.5")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SpellChecker",
            dependencies: ["MorphologicalAnalysis", "NGram"],
            resources: [.process("merged.txt"),.process("split.txt"),.process("ngram.txt")]),
        .testTarget(
            name: "SpellCheckerTests",
            dependencies: ["SpellChecker"]),
    ]
)
