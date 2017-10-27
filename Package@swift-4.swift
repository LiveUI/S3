// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "S3SignerAWS",
  products: [
    .library(name: "S3SignerAWS", targets: ["S3SignerAWS"])
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/crypto.git", .upToNextMajor(from: "2.0.0")),
  ],
  targets: [
    .target(name: "S3SignerAWS", dependencies: ["Crypto"], path: "Sources"),
    .testTarget(name: "S3SignerAWSTests", dependencies: ["S3SignerAWS"]),
  ]
)
