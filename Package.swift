// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "S3Kit",
    products: [
        .library(name: "S3Kit", targets: ["S3Kit"]),
        .library(name: "S3Signer", targets: ["S3Signer"]),
//        .library(name: "S3TestTools", targets: ["S3TestTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.5.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.3"),
        .package(url: "https://github.com/vapor/open-crypto.git", from: "4.0.0-alpha.2"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0-alpha.2"),
        .package(url: "https://github.com/Einstore/HTTPMediaTypes.git", from: "0.0.1"),
        .package(url: "https://github.com/Einstore/WebErrorKit.git", from: "0.0.1"),
        .package(url: "https://github.com/LiveUI/XMLCoding.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "S3Kit",
            dependencies: [
                "S3Signer",
                "AsyncHTTPClient",
                "HTTPMediaTypes",
                "XMLCoding"
            ]
        ),
        .target(
            name: "S3Provider",
            dependencies: [
                "Vapor",
                "S3Kit"
            ]
        ),
        .target(
            name: "S3DemoRun",
            dependencies: [
                "Vapor",
                "S3Provider"
            ]
        ),
        .target(
            name: "S3Signer",
            dependencies: [
                "OpenCrypto",
                "NIOHTTP1",
                "HTTPMediaTypes",
                "WebErrorKit"
            ]
        ),
//        .target(name: "S3TestTools", dependencies: [
//            "Vapor",
//            "S3Kit"
//            ]
//        ),
        .testTarget(name: "S3Tests", dependencies: [
            "S3Kit"
            ]
        )
    ]
)
