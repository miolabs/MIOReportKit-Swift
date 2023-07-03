// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "MIOReportKit-Swift",
    platforms: [
        .macOS(.v11), .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MIOReportKit-Swift",
            targets: ["MIOReportKit-Swift"]),
    ],
    dependencies: [
        .package( url: "https://github.com/miolabs/MIOCore.git", .branch("master") ),
        .package( url: "https://github.com/miolabs/PDFLib-Swift.git", .branch("main") )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MIOReportKit-Swift",
            dependencies: [
                .product(name: "MIOCore", package: "MIOCore" ),
                .product(name: "PDFLib-Swift", package: "PDFLib-Swift", condition: .when( platforms: [.macOS, .linux] ) )
            ] ),
        .testTarget(
            name: "MIOReportKit-SwiftTests",
            dependencies: ["MIOReportKit-Swift"]),
    ]
)
