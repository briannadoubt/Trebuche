# Changelog

All notable changes to Trebuchet will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Breaking Changes

#### Removed deprecated APIs

The following deprecated APIs have been removed. Please update your code to use the new equivalents:

**TrebuchetSecurity - JWTAuthenticator**
- Removed `SigningKey.symmetric(secret:)` → Use `SigningKey.hs256(secret:)` instead
- Removed `SigningKey.asymmetric(publicKey:)` → Use `SigningKey.es256(publicKey:)` instead

**Trebuchet - SwiftUI View Modifiers**
- Removed `View.trebuchetClient(transport:reconnectionPolicy:autoConnect:)` → Use `View.trebuchet(transport:reconnectionPolicy:autoConnect:)` instead

### Migration Guide

**Before:**
```swift
// JWT Authentication
let key = SigningKey.symmetric(secret: "my-secret")
let key = SigningKey.asymmetric(publicKey: publicKey)

// SwiftUI
ContentView()
    .trebuchetClient(transport: .webSocket(host: "localhost", port: 8080))
```

**After:**
```swift
// JWT Authentication
let key = SigningKey.hs256(secret: "my-secret")
let key = SigningKey.es256(publicKey: publicKey)

// SwiftUI
ContentView()
    .trebuchet(transport: .webSocket(host: "localhost", port: 8080))
```

### Added

- PostgreSQL integration tests with Docker Compose infrastructure
- Full LISTEN/NOTIFY stream adapter implementation with end-to-end verification
- Comprehensive test documentation in `Tests/TrebuchetPostgreSQLTests/README.md`

### Fixed

- PostgreSQL healthcheck now uses correct database name
- Integration tests use unique actor IDs to prevent conflicts
- NOTIFY test now actually verifies notification delivery through stream

---

## Release History

This is the initial changelog. Previous releases were not tracked in this format.
