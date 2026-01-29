# ``Trebuchet/TransportConfiguration``

## Overview

`TransportConfiguration` specifies how Trebuchet communicates over the network. It's used when creating servers and clients.

## WebSocket Transport

WebSocket is the recommended transport for most use cases:

```swift
// Server - listen on all interfaces
.webSocket(port: 8080)

// Server - specific interface
.webSocket(host: "192.168.1.100", port: 8080)

// Client
.webSocket(host: "game.example.com", port: 8080)
```

### With TLS

For secure connections, provide a ``TLSConfiguration``:

```swift
let tls = try TLSConfiguration(
    certificatePath: "/etc/ssl/certs/server.pem",
    privateKeyPath: "/etc/ssl/private/server.key"
)

.webSocket(host: "0.0.0.0", port: 8443, tls: tls)
```

## TCP Transport

TCP transport provides efficient server-to-server communication with minimal protocol overhead:

```swift
// Server - listen on all interfaces
.tcp(port: 9001)

// Server - specific interface
.tcp(host: "192.168.1.100", port: 9001)

// Client
.tcp(host: "server.local", port: 9001)
```

TCP transport is ideal for:
- Internal service-to-service communication
- Trusted network environments (VPC, private networks)
- Scenarios where WebSocket handshake overhead is unnecessary
- Multi-machine deployments (e.g., Fly.io)

**Security Note:** TCP transport does not support TLS. Use WebSocket with TLS for public networks, or deploy TCP within a trusted network boundary.

See ``TCPTransport`` for detailed usage and security considerations.

## Topics

### Transport Types

- ``webSocket(host:port:tls:)``
- ``tcp(host:port:)``

### Properties

- ``endpoint``
- ``tlsEnabled``
- ``tlsConfiguration``
