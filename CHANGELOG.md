# Changelog

All notable changes to Trebuchet will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-01-30

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

#### AWS Integration (Production-Ready)
- **Complete Soto SDK Integration**: Migrated from SmokeLambda to official AWS SDK for production reliability
  - DynamoDB for actor state persistence with optimistic locking
  - CloudWatch for metrics and observability
  - Cloud Map for service discovery
  - Lambda for serverless actor deployment
  - IAM for role management
  - API Gateway WebSocket for connection management
- **LocalStack Integration Tests**: Comprehensive test suite for AWS services
  - Automatic LocalStack initialization scripts
  - DynamoDB state store tests with versioning
  - Cloud Map registry tests
  - End-to-end workflow tests
  - Full documentation in `Tests/TrebuchetAWSTests/README.md`

#### Production Features
- **State Versioning**: Optimistic concurrency control for actor state
  - Conditional updates prevent lost writes
  - Automatic version tracking and conflict detection
- **Protocol Versioning**: Client-server compatibility handling
  - Version negotiation for distributed systems
  - Graceful degradation support
- **Graceful Shutdown**: Clean actor lifecycle management
  - Proper resource cleanup
  - In-flight request completion
  - Connection draining

#### Streaming & Cloud Gateway
- **Stream Resumption**: Resume streams from last known position after disconnection
  - Automatic sequence tracking
  - Reliable state synchronization
- **CloudGateway.process()**: Programmatic actor invocation for actor-to-actor calls
  - Direct method invocation without HTTP overhead
  - Lambda-to-Lambda communication support
- **WebSocket Lambda Handler**: RPC execution via CloudGateway in AWS Lambda
  - Full WebSocket support for serverless deployments
  - API Gateway integration

#### Testing & Quality
- **SwiftUI Integration Tests**: 325 lines covering connection lifecycle, state management, and multi-server scenarios
- **CLI Configuration Tests**: 610 lines testing configuration parsing, validation, and build system
  - Provider compatibility validation
  - Resource limit enforcement
  - State store and discovery mechanism compatibility checks
- **Configuration Validation**: Comprehensive validation to prevent misconfigurations
  - Rejects unimplemented providers (GCP, Azure, Kubernetes)
  - Validates provider-specific requirements
  - Enforces memory limits (128MB - 10GB)
  - Enforces timeout limits (1s - 900s)
- **Platform Compatibility**: Linux compatibility fixes with platform guards
  - SwiftUI tests properly guarded for macOS-only APIs
  - Executable target import workarounds for Linux

#### PostgreSQL Enhancements
- **LISTEN/NOTIFY Stream Adapter**: Full implementation for multi-instance synchronization
  - Real-time state broadcasting across PostgreSQL-backed instances
  - Automatic reconnection and channel management
- **Docker Compose Infrastructure**: PostgreSQL integration tests with automated setup
  - Healthcheck verification
  - Unique actor IDs for test isolation
- **Comprehensive Documentation**: `Tests/TrebuchetPostgreSQLTests/README.md` with setup and troubleshooting

#### Developer Experience
- **Improved Error Messages**: Better validation and debugging guidance
- **CLAUDE.md Updates**: Critical debugging instructions to never guess without seeing actual error logs
- **LocalStack Setup**: Streamlined initialization with automatic resource creation

- **TCP Transport**: Production-ready TCP transport for efficient server-to-server communication
  - Length-prefixed message framing (4-byte big-endian) via NIOExtras
  - Connection pooling with automatic stale connection cleanup
  - Idle connection timeout (5 minutes) to prevent resource leaks
  - Backpressure handling with 30-second write timeout
  - Optimized EventLoopGroup thread count (2-4 threads for I/O workloads)
  - Full integration with TrebuchetServer and TrebuchetClient
  - Comprehensive test suite with 12 integration tests including error scenarios
  - Security: Designed for trusted networks only (no TLS support)
  - Ideal for actor-to-actor communication in multi-machine deployments (e.g., Fly.io)
  - Usage: `.tcp(host: "0.0.0.0", port: 9001)`
- PostgreSQL integration tests with Docker Compose infrastructure
- Full LISTEN/NOTIFY stream adapter implementation with end-to-end verification
- Comprehensive test documentation in `Tests/TrebuchetPostgreSQLTests/README.md`

### Fixed

- **PostgreSQL**: Healthcheck now uses correct database name
- **PostgreSQL**: Integration tests use unique actor IDs to prevent conflicts
- **PostgreSQL**: NOTIFY test now actually verifies notification delivery through stream
- **Linux Build**: Platform guards for SwiftUI and executable target imports
- **AWS**: CloudClient credential handling improvements
- **DynamoDB**: Soto SDK workarounds for AWSBase64Data extraction
- **Configuration**: Provider validation prevents deployment failures for unimplemented providers

---

## Release History

This is the initial changelog. Previous releases were not tracked in this format.
