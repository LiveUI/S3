// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "S3Kit",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "S3Kit", targets: ["S3Kit"]),
        .library(name: "S3Signer", targets: ["S3Signer"]),
        //        .library(name: "S3TestTools", targets: ["S3TestTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc.3.11"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.13.1"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
        .package(url: "https://github.com/Einstore/HTTPMediaTypes.git", from: "0.0.1"),
        .package(name: "WebError", url: "https://github.com/Einstore/WebErrorKit.git", from: "0.0.1"),
        .package(url: "https://github.com/LiveUI/XMLCoding.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "S3Kit",
            dependencies: [
                .target(name: "S3Signer"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "XMLCoding", package: "XMLCoding"),
                .product(name: "HTTPMediaTypes", package: "HTTPMediaTypes")
            ]
        ),
        .target(
            name: "S3",
            dependencies: [
                .target(name: "S3Kit"),
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .target(
            name: "S3DemoRun",
            dependencies: [
                .target(name: "S3"),
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .target(
            name: "S3Signer",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "HTTPMediaTypes", package: "HTTPMediaTypes"),
                .product(name: "WebErrorKit", package: "WebError"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ]
        ),
        //        .target(name: "S3TestTools", dependencies: [
        //            "Vapor",
        //            "S3Kit"
        //            ]
        //        ),
        .testTarget(name: "S3Tests", dependencies: [
            .target(name: "S3Kit")
            ]
        )
    ]
)
