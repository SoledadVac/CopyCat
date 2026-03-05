import Foundation

@MainActor
class ConnectionManager: ObservableObject {
    @Published var connections: [ConnectionConfig] = []
    @Published var selectedConnection: ConnectionConfig?
    @Published var isConnected: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let connectionsKey = "CopyCat.Connections"
    
    init() {
        loadConnections()
    }
    
    func loadConnections() {
        guard let data = userDefaults.data(forKey: connectionsKey),
              let decoded = try? JSONDecoder().decode([ConnectionConfig].self, from: data) else {
            return
        }
        connections = decoded
    }
    
    func saveConnections() {
        guard let data = try? JSONEncoder().encode(connections) else {
            return
        }
        userDefaults.set(data, forKey: connectionsKey)
    }
    
    func addConnection(_ config: ConnectionConfig) {
        connections.append(config)
        saveConnections()
    }
    
    func updateConnection(_ config: ConnectionConfig) {
        guard let index = connections.firstIndex(where: { $0.id == config.id }) else {
            return
        }
        connections[index] = config
        saveConnections()
    }
    
    func deleteConnection(_ config: ConnectionConfig) {
        connections.removeAll { $0.id == config.id }
        if selectedConnection?.id == config.id {
            selectedConnection = nil
            isConnected = false
        }
        saveConnections()
    }
    
    func testConnection(_ config: ConnectionConfig) async throws -> Bool {
        switch config.type {
        case .sqlite:
            return try await testSQLiteConnection(config)
        default:
            return try await testGenericConnection(config)
        }
    }
    
    private func testSQLiteConnection(_ config: ConnectionConfig) async throws -> Bool {
        guard let filePath = config.filePath else {
            throw ConnectionError.invalidConfiguration
        }
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    private func testGenericConnection(_ config: ConnectionConfig) async throws -> Bool {
        return true
    }
    
    func connect(to config: ConnectionConfig) async throws {
        let success = try await testConnection(config)
        if success {
            selectedConnection = config
            isConnected = true
            var updatedConfig = config
            updatedConfig.lastConnectedAt = Date()
            updateConnection(updatedConfig)
        }
    }
    
    func disconnect() {
        selectedConnection = nil
        isConnected = false
    }
}

enum ConnectionError: Error {
    case invalidConfiguration
    case connectionFailed
}
