# Trebuche

Location-transparent distributed actors for Swift. Make RPC stupid simple.

[![Documentation](https://img.shields.io/badge/docs-DocC-blue)](https://briannadoubt.github.io/Trebuche/documentation/trebuche/)

## Overview

Trebuche is a Swift 6.2 distributed actor framework that lets you define actors once and use them seamlessly whether they're local or remote.

```swift
@Trebuchet
distributed actor GameRoom {
    distributed func join(player: Player) -> RoomState
}
```

## Installation

### Library

Add Trebuche to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/briannadoubt/Trebuche.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "MyApp",
    dependencies: ["Trebuche"]
)
```

### CLI Tool

Install the `trebuche` CLI for cloud deployment:

```bash
# Using Mint (recommended)
mint install briannadoubt/Trebuche

# Or build from source
git clone https://github.com/briannadoubt/Trebuche.git
cd Trebuche
swift build -c release
cp .build/release/trebuche /usr/local/bin/
```

## Quick Start

### Server

```swift
import Trebuche

let server = TrebuchetServer(transport: .webSocket(port: 8080))
let room = GameRoom(actorSystem: server.actorSystem)
await server.expose(room, as: "main-room")
try await server.run()
```

### Client

```swift
import Trebuche

let client = TrebuchetClient(transport: .webSocket(host: "localhost", port: 8080))
try await client.connect()

let room = try client.resolve(GameRoom.self, id: "main-room")
try await room.join(player: me)  // Looks local, works remotely!
```

## Cloud Deployment

Deploy your actors to AWS Lambda with a single command:

```bash
# Initialize configuration
trebuche init --name my-game-server --provider aws

# Preview deployment
trebuche deploy --dry-run

# Deploy to AWS
trebuche deploy --provider aws --region us-east-1
```

The CLI discovers your `@Trebuchet` actors, generates Terraform, and deploys to:
- **AWS Lambda** for actor execution
- **DynamoDB** for state persistence
- **CloudMap** for service discovery

See the [Cloud Deployment Guide](https://briannadoubt.github.io/Trebuche/documentation/trebuche/clouddeploymentoverview) for details.

## Documentation

Full documentation is available at **[briannadoubt.github.io/Trebuche](https://briannadoubt.github.io/Trebuche/documentation/trebuche/)**.

## Requirements

- Swift 6.2+
- macOS 14+ / iOS 17+ / tvOS 17+ / watchOS 10+

## License

MIT
