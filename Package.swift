import PackageDescription

let package = Package(
    name: "S3SignerAWS",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/vapor/crypto.git",
                 Version(2,0,0, prereleaseIdentifiers: ["beta"])),
        .Package(url: "https://github.com/vapor/core.git", Version(2,0,0, prereleaseIdentifiers: ["beta"]))
    ]
)
