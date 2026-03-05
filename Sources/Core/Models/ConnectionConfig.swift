import Foundation

enum DatabaseType: String, Codable, CaseIterable, Identifiable {
    case mysql
    case mariadb
    case oracle
    case sqlServer
    case postgresql
    case sqlite
    case mongodb
    case redis
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .mysql: return "MySQL"
        case .mariadb: return "MariaDB"
        case .oracle: return "Oracle"
        case .sqlServer: return "SQL Server"
        case .postgresql: return "PostgreSQL"
        case .sqlite: return "SQLite"
        case .mongodb: return "MongoDB"
        case .redis: return "Redis"
        }
    }
    
    var defaultPort: Int? {
        switch self {
        case .mysql: return 3306
        case .mariadb: return 3306
        case .oracle: return 1521
        case .sqlServer: return 1433
        case .postgresql: return 5432
        case .sqlite: return nil
        case .mongodb: return 27017
        case .redis: return 6379
        }
    }
}

struct ConnectionConfig: Codable, Identifiable {
    let id: UUID
    var name: String
    var type: DatabaseType
    var host: String?
    var port: Int?
    var username: String?
    var database: String?
    var filePath: String?
    var useSSL: Bool
    var useSSH: Bool
    var sshHost: String?
    var sshPort: Int?
    var sshUsername: String?
    var colorTag: String?
    var groupName: String?
    var createdAt: Date
    var lastConnectedAt: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        type: DatabaseType,
        host: String? = nil,
        port: Int? = nil,
        username: String? = nil,
        database: String? = nil,
        filePath: String? = nil,
        useSSL: Bool = false,
        useSSH: Bool = false,
        sshHost: String? = nil,
        sshPort: Int? = nil,
        sshUsername: String? = nil,
        colorTag: String? = nil,
        groupName: String? = nil,
        createdAt: Date = Date(),
        lastConnectedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.host = host
        self.port = port
        self.username = username
        self.database = database
        self.filePath = filePath
        self.useSSL = useSSL
        self.useSSH = useSSH
        self.sshHost = sshHost
        self.sshPort = sshPort
        self.sshUsername = sshUsername
        self.colorTag = colorTag
        self.groupName = groupName
        self.createdAt = createdAt
        self.lastConnectedAt = lastConnectedAt
    }
}
