import PackageDescription

let package = Package(
    name: "S3SignerAWS",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/vapor/crypto.git",
                 majorVersion: 1),
        .Package(url: "https://github.com/vapor/core.git", majorVersion: 1)
    ]
)
