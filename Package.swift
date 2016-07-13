import PackageDescription

let package = Package(
    name: "OpenCloudKit",
    dependencies: [
        .Package(url: "https://github.com/BennyKJohnson/COpenSSL", majorVersion: 0, minor: 1),
        ]
)
