# OpenCloudKit
An open source framework for CloudKit written in Swift and inspired by Apple's CloudKit framework. 
OpenCloudKit is backed by CloudKit Web Services and is designed to allow easy CloudKit integration into Swift Servers whilst being familiar for developers who have experience with CloudKit on Apple's platforms.

# Installation

## Installing Dependencies 
OpenSSL is the only dependency required by OpenCloudKit, it is required to perform the signature generation for Server-to-Server support. 

### macOS
Install `openssl` with `Homebrew`
```sh
brew install openssl
brew link openssl --force # OpenSSL headers & dylib are not symlinked to /usr/local by default
```

### Linux
Install `libssl-dev` using `apt-get`
```sh
apt-get install libssl-dev
```
## Swift Package Manager
Add the following to dependencies in your `Package.swift`.
```swift
.Package(url: "https://github.com/BennyKJohnson/OpenCloudKit.git", majorVersion: 0, minor: 1)
```
Or create the 'Package.swift' file for your project and add the following:
```swift
import PackageDescription

let package = Package(
	dependencies: [
		.Package(url: "https://github.com/BennyKJohnson/OpenCloudKit.git", majorVersion: 0, minor: 1),
	]
)
```
