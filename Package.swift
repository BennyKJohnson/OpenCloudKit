import PackageDescription

let package = Package(
    name: "OpenCloudKit",
    dependencies: [
        .Package(url: "https://github.com/vapor/clibressl.git", majorVersion: 1),
        .Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", majorVersion: 0),
        .Package(url: "https://github.com/czechboy0/Jay.git", majorVersion: 1)
        ]
)

#if os(Linux)
    package.exclude.append("Sources/CLLocation+OpenCloudKit.swift")
#endif
 
