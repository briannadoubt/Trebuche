import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Trebuche
import TrebucheCloud

// MARK: - API Gateway Connection Sender

/// Production API Gateway Management API-based connection sender.
///
/// This implementation sends data to WebSocket connections using the
/// API Gateway Management API's POST-to-connection endpoint.
///
/// ## API Gateway Management API
///
/// Endpoint format: `https://{api-id}.execute-api.{region}.amazonaws.com/{stage}/@connections/{connectionId}`
///
/// The Management API provides:
/// - `POST /@connections/{connectionId}` - Send data to a connection
/// - `GET /@connections/{connectionId}` - Get connection info
/// - `DELETE /@connections/{connectionId}` - Disconnect a client
///
/// ## Example Usage
///
/// ```swift
/// let sender = APIGatewayConnectionSender(
///     endpoint: "https://abc123.execute-api.us-east-1.amazonaws.com/production",
///     region: "us-east-1"
/// )
///
/// try await sender.send(data: messageData, to: "connection-id-123")
/// ```
///
/// ## Error Handling
///
/// - 410 Gone: Connection no longer exists (client disconnected)
/// - 403 Forbidden: Invalid credentials or permissions
/// - 500 Internal Server Error: API Gateway internal error
///
public actor APIGatewayConnectionSender: ConnectionSender {
    private let endpoint: String
    private let region: String
    private let credentials: AWSCredentials

    /// Initialize with API Gateway WebSocket endpoint
    ///
    /// - Parameters:
    ///   - endpoint: The API Gateway WebSocket API endpoint (e.g., "https://abc123.execute-api.us-east-1.amazonaws.com/production")
    ///   - region: AWS region (default: "us-east-1")
    ///   - credentials: AWS credentials (default: uses environment/IAM role)
    public init(
        endpoint: String,
        region: String = "us-east-1",
        credentials: AWSCredentials = .default
    ) {
        // Remove trailing slash if present
        self.endpoint = endpoint.hasSuffix("/") ? String(endpoint.dropLast()) : endpoint
        self.region = region
        self.credentials = credentials
    }

    public func send(data: Data, to connectionID: String) async throws {
        // Build URL: {endpoint}/@connections/{connectionId}
        let urlString = "\(endpoint)/@connections/\(connectionID)"

        guard let url = URL(string: urlString) else {
            throw ConnectionError.invalidData
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Simplified auth - production should use AWS Signature V4
        if let accessKey = credentials.accessKeyId {
            request.setValue(accessKey, forHTTPHeaderField: "X-Amz-Access-Key")
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConnectionError.sendFailed("Invalid response from API Gateway")
        }

        switch httpResponse.statusCode {
        case 200:
            // Success
            return

        case 410:
            // Connection gone (client disconnected)
            throw ConnectionError.connectionClosed

        case 403:
            throw ConnectionError.sendFailed("API Gateway forbidden (check credentials/permissions)")

        case 500, 502, 503, 504:
            throw ConnectionError.sendFailed("API Gateway internal error (\(httpResponse.statusCode))")

        default:
            throw ConnectionError.sendFailed("API Gateway error: \(httpResponse.statusCode)")
        }
    }

    public func isAlive(connectionID: String) async -> Bool {
        // Use GET /@connections/{connectionId} to check if connection exists
        let urlString = "\(endpoint)/@connections/\(connectionID)"

        guard let url = URL(string: urlString) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Simplified auth
        if let accessKey = credentials.accessKeyId {
            request.setValue(accessKey, forHTTPHeaderField: "X-Amz-Access-Key")
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            // 200 = connection exists
            // 410 = connection gone
            return httpResponse.statusCode == 200
        } catch {
            return false
        }
    }

    // MARK: - Additional Management API Methods

    /// Disconnect a client connection
    ///
    /// Uses DELETE /@connections/{connectionId} to force-disconnect a client.
    ///
    /// - Parameter connectionID: The connection to disconnect
    public func disconnect(connectionID: String) async throws {
        let urlString = "\(endpoint)/@connections/\(connectionID)"

        guard let url = URL(string: urlString) else {
            throw ConnectionError.invalidData
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        if let accessKey = credentials.accessKeyId {
            request.setValue(accessKey, forHTTPHeaderField: "X-Amz-Access-Key")
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConnectionError.sendFailed("Invalid response from API Gateway")
        }

        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 410 else {
            throw ConnectionError.sendFailed("API Gateway disconnect error: \(httpResponse.statusCode)")
        }
    }

    /// Get connection information
    ///
    /// Uses GET /@connections/{connectionId} to retrieve connection metadata.
    ///
    /// - Parameter connectionID: The connection to query
    /// - Returns: Connection metadata including connected time
    public func getConnectionInfo(connectionID: String) async throws -> ConnectionInfo {
        let urlString = "\(endpoint)/@connections/\(connectionID)"

        guard let url = URL(string: urlString) else {
            throw ConnectionError.invalidData
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let accessKey = credentials.accessKeyId {
            request.setValue(accessKey, forHTTPHeaderField: "X-Amz-Access-Key")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConnectionError.sendFailed("Invalid response from API Gateway")
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 410 {
                throw ConnectionError.connectionClosed
            }
            throw ConnectionError.sendFailed("API Gateway error: \(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()
        return try decoder.decode(ConnectionInfo.self, from: data)
    }
}

// MARK: - Connection Info

/// Connection information from API Gateway Management API
public struct ConnectionInfo: Codable, Sendable {
    /// Time the connection was established (ISO 8601)
    public let connectedAt: String

    /// Source IP address
    public let sourceIp: String?

    /// User agent string
    public let userAgent: String?

    enum CodingKeys: String, CodingKey {
        case connectedAt
        case sourceIp = "identity.sourceIp"
        case userAgent = "identity.userAgent"
    }
}
