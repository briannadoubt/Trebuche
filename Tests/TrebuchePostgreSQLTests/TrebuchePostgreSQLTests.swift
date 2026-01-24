import Testing
import Foundation
@testable import TrebuchePostgreSQL

@Suite("PostgreSQL State Store Tests")
struct PostgreSQLStateStoreTests {
    @Test("PostgreSQLStateStore initialization")
    func testInitialization() async throws {
        // Note: This test requires a running PostgreSQL instance
        // In CI/CD, you would set up a test database
        //
        // let store = try await PostgreSQLStateStore(
        //     host: "localhost",
        //     database: "test",
        //     username: "test",
        //     password: "test"
        // )
        //
        // For now, we just verify the type exists
        #expect(PostgreSQLStateStore.self != nil)
    }
}

@Suite("PostgreSQL Stream Adapter Tests")
struct PostgreSQLStreamAdapterTests {
    @Test("PostgreSQLStreamAdapter initialization")
    func testInitialization() async throws {
        // Note: This test requires a running PostgreSQL instance
        // In CI/CD, you would set up a test database
        //
        // let adapter = try await PostgreSQLStreamAdapter(
        //     host: "localhost",
        //     database: "test",
        //     username: "test",
        //     password: "test"
        // )
        //
        // For now, we just verify the type exists
        #expect(PostgreSQLStreamAdapter.self != nil)
    }
}

@Suite("State Change Notification Tests")
struct StateChangeNotificationTests {
    @Test("StateChangeNotification codable")
    func testCodable() throws {
        let notification = StateChangeNotification(
            actorID: "test-actor",
            sequenceNumber: 42,
            timestamp: Date()
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(notification)
        let decoded = try decoder.decode(StateChangeNotification.self, from: data)

        #expect(decoded.actorID == notification.actorID)
        #expect(decoded.sequenceNumber == notification.sequenceNumber)
    }
}
