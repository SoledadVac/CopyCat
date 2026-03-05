import Foundation

struct QueryHistory: Codable, Identifiable, Hashable {
    let id: UUID
    let connectionId: UUID
    var query: String
    var resultCount: Int?
    var executionTime: TimeInterval?
    var success: Bool
    var errorMessage: String?
    var executedAt: Date
    
    init(
        id: UUID = UUID(),
        connectionId: UUID,
        query: String,
        resultCount: Int? = nil,
        executionTime: TimeInterval? = nil,
        success: Bool,
        errorMessage: String? = nil,
        executedAt: Date = Date()
    ) {
        self.id = id
        self.connectionId = connectionId
        self.query = query
        self.resultCount = resultCount
        self.executionTime = executionTime
        self.success = success
        self.errorMessage = errorMessage
        self.executedAt = executedAt
    }
}
