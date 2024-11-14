// swift-tools-version:5.9
import PackageDescription
import Foundation

let package = Package(
    name: "S3Kit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "S3Kit", targets: ["S3Kit"]),
        .library(name: "S3Signer", targets: ["S3Signer"]),
        //        .library(name: "S3TestTools", targets: ["S3TestTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.5.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "4.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
        .package(url: "https://github.com/Einstore/HTTPMediaTypes.git", from: "0.0.1"),
        .package(url: "https://github.com/Einstore/WebErrorKit.git", from: "0.0.1"),
        .package(url: "https://github.com/LiveUI/XMLCoding.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "S3Kit",
            dependencies: [
                .target(name: "S3Signer"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "HTTPMediaTypes", package: "HTTPMediaTypes"),
                .product(name: "XMLCoding", package: "XMLCoding"),
            ]
        ),
        .target(
            name: "S3Provider",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "S3Kit"),
            ]
        ),
        .target(
            name: "S3Signer",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "HTTPMediaTypes", package: "HTTPMediaTypes"),
                .product(name: "WebErrorKit", package: "WebErrorKit"),
            ]
        ),
        .testTarget(
            name: "S3Tests",
            dependencies: [
                .target(name: "S3Kit"),
            ]
        ),
    ]
)
