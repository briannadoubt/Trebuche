# ``Trebuchet/TrebuchetTransport``

## Overview

`TrebuchetTransport` is the protocol for network transport implementations. Trebuchet includes WebSocket and TCP transports, and you can implement custom transports for different protocols.

## Built-in Transports

### WebSocket Transport

WebSocket transport provides bidirectional communication with browser compatibility:

```swift
// Server
TrebuchetServer(transport: .webSocket(port: 8080))

// Client
TrebuchetClient(transport: .webSocket(host: "localhost", port: 8080))
```

WebSocket is recommended for:
- Browser clients
- Public networks with TLS
- Maximum compatibility

### TCP Transport

TCP transport provides low-overhead server-to-server communication:

```swift
// Server
TrebuchetServer(transport: .tcp(port: 9001))

// Client
TrebuchetClient(transport: .tcp(host: "server.local", port: 9001))
```

TCP is recommended for:
- Internal service-to-service communication
- Trusted networks (VPC, private networks)
- Minimal protocol overhead

See ``TCPTransport`` for detailed documentation.

## Custom Transports

Implement `TrebuchetTransport` to add support for other protocols:

```swift
public struct MyCustomTransport: TrebuchetTransport {
    public func send(_ data: Data, to endpoint: Endpoint) async throws {
        // Send data to the endpoint
    }

    public func listen(on endpoint: Endpoint) async throws {
        // Start listening for connections
    }

    public func shutdown() async {
        // Clean up resources
    }

    public var incoming: AsyncStream<TransportMessage> {
        // Return stream of incoming messages
    }
}
```

## Topics

### Protocol Requirements

- ``send(_:to:)``
- ``listen(on:)``
- ``shutdown()``
- ``incoming``
