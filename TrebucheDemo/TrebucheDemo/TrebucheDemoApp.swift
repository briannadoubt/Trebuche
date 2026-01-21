//
//  TrebucheDemoApp.swift
//  TrebucheDemo
//
//  Created by Brianna Zamora on 1/20/26.
//

import SwiftUI
import Trebuche

@main
struct TrebucheDemoApp: App {
    /// The Trebuche server running locally
    @State private var server: TrebuchetServer?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .trebuche(transport: .webSocket(host: "127.0.0.1", port: 8080))
                .task {
                    await startServer()
                }
        }
    }

    /// Start the local Trebuche server with a TodoList actor
    private func startServer() async {
        let server = TrebuchetServer(transport: .webSocket(port: 8080))
        self.server = server

        // Create and expose the TodoList actor
        let todoList = TodoList(actorSystem: server.actorSystem)
        await server.expose(todoList, as: "todos")

        // Run the server
        do {
            try await server.run()
        } catch {
            print("Server error: \(error)")
        }
    }
}
