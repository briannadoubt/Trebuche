# ``Trebuchet/TCPTransport``

## Overview

`TCPTransport` provides efficient, low-overhead communication between distributed actor systems using raw TCP sockets with length-prefixed message framing.

This transport is ideal for server-to-server communication in trusted network environments where you don't need browser compatibility and want minimal protocol overhead.

## When to Use TCP Transport

Use TCP transport when:
- Communication is server-to-server (not browser clients)
- You're deploying in a trusted network (VPC, private network, localhost)
- You want minimal protocol overhead
- WebSocket handshake overhead is unnecessary

Use WebSocket transport when:
- You need browser client support
- You're communicating over public networks
- You need TLS encryption support
- You want broader compatibility

## Security Considerations

**IMPORTANT:** TCP transport does NOT support TLS encryption.

For secure communication:
- Deploy within a trusted network (VPC, private network, localhost)
- Use WebSocket transport with TLS for public networks
- Use a TLS termination proxy (nginx, Envoy) if TLS is required

This transport is designed for internal service-to-service communication within secure network boundaries.

## Message Framing

Messages are framed with a 4-byte big-endian length prefix:
```
[4 bytes: message length][message payload]
```

This framing prevents message boundaries from being ambiguous and enables efficient parsing of the message stream.

## Usage

### Server

```swift
import Trebuchet

let server = TrebuchetServer(transport: .tcp(host: "0.0.0.0", port: 9001))
let gameRoom = GameRoom(actorSystem: server.actorSystem)
await server.expose(gameRoom, as: "main-room")
try await server.run()
```

### Client

```swift
import Trebuchet

let client = TrebuchetClient(transport: .tcp(host: "server.local", port: 9001))
try await client.connect()

let room = try client.resolve(GameRoom.self, id: "main-room")
try await room.join(player: me)
```

## Connection Management

TCP transport includes built-in connection pooling:
- Outgoing connections are reused for multiple calls
- Idle connections are cleaned up after 5 minutes
- Write operations timeout after 30 seconds to prevent hanging
- Stale connections are automatically removed

## Performance Characteristics

TCP transport is optimized for I/O-bound server-to-server workloads:
- Uses 2-4 threads for event loop processing
- Efficient memory usage with NIO buffer management
- Minimal framing overhead (4 bytes per message)
- Connection pooling reduces handshake overhead

## Topics

### Creating TCP Transport

- ``init(eventLoopGroup:)``

### Protocol Conformance

- ``TrebuchetTransport``
