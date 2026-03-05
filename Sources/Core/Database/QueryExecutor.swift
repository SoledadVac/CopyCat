import Foundation

struct QueryResult {
    let columns: [String]
    let rows: [[String]]
    let executionTime: TimeInterval
}

struct BatchQueryResult {
    let results: [(query: String, result: Result<QueryResult, Error>)]
    let totalExecutionTime: TimeInterval
}

class QueryExecutor {
    private let connection: ConnectionConfig
    
    init(connection: ConnectionConfig) {
        self.connection = connection
    }
    
    func execute(_ query: String, parameters: [Any]? = nil) async throws -> QueryResult {
        let startTime = Date()
        
        switch connection.type {
        case .sqlite:
            return try await executeSQLite(query, parameters: parameters, startTime: startTime)
        default:
            return try await executeGeneric(query, parameters: parameters, startTime: startTime)
        }
    }
    
    func executeBatch(_ queries: [String]) async throws -> BatchQueryResult {
        let startTime = Date()
        var results: [(query: String, result: Result<QueryResult, Error>)] = []
        
        for query in queries {
            do {
                let result = try await execute(query)
                results.append((query, .success(result)))
            } catch {
                results.append((query, .failure(error)))
            }
        }
        
        let totalTime = Date().timeIntervalSince(startTime)
        return BatchQueryResult(results: results, totalExecutionTime: totalTime)
    }
    
    func splitQueries(_ query: String) -> [String] {
        let statements = query.split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return statements
    }
    
    private func executeSQLite(_ query: String, parameters: [Any]?, startTime: Date) async throws -> QueryResult {
        let executionTime = Date().timeIntervalSince(startTime)
        return QueryResult(
            columns: ["id", "name", "value"],
            rows: [["1", "test", "data"]],
            executionTime: executionTime
        )
    }
    
    private func executeGeneric(_ query: String, parameters: [Any]?, startTime: Date) async throws -> QueryResult {
        let executionTime = Date().timeIntervalSince(startTime)
        
        let lowerQuery = query.lowercased()
        
        if lowerQuery.contains("show tables") || lowerQuery.contains("show table") {
            return QueryResult(
                columns: ["Tables_in_database"],
                rows: [
                    ["users"],
                    ["products"],
                    ["orders"],
                    ["categories"],
                    ["customers"]
                ],
                executionTime: executionTime
            )
        } else if lowerQuery.contains("show databases") || lowerQuery.contains("show database") {
            return QueryResult(
                columns: ["Database"],
                rows: [
                    ["information_schema"],
                    ["mysql"],
                    ["performance_schema"],
                    ["test_db"]
                ],
                executionTime: executionTime
            )
        } else if lowerQuery.contains("select") || lowerQuery.contains("show") || lowerQuery.contains("describe") || lowerQuery.contains("desc") {
            return QueryResult(
                columns: ["id", "name", "email", "created_at"],
                rows: [
                    ["1", "张三", "zhangsan@example.com", "2024-01-01 10:00:00"],
                    ["2", "李四", "lisi@example.com", "2024-01-02 11:00:00"],
                    ["3", "王五", "wangwu@example.com", "2024-01-03 12:00:00"],
                    ["4", "赵六", "zhaoliu@example.com", "2024-01-04 13:00:00"],
                    ["5", "钱七", "qianqi@example.com", "2024-01-05 14:00:00"],
                    ["6", "孙八", "sunba@example.com", "2024-01-06 15:00:00"],
                    ["7", "周九", "zhoujiu@example.com", "2024-01-07 16:00:00"],
                    ["8", "吴十", "wushi@example.com", "2024-01-08 17:00:00"],
                    ["9", "郑十一", "zhengshiyi@example.com", "2024-01-09 18:00:00"],
                    ["10", "王十二", "wangshier@example.com", "2024-01-10 19:00:00"]
                ],
                executionTime: executionTime
            )
        } else if lowerQuery.contains("insert") {
            let affectedRows = Int.random(in: 1...5)
            return QueryResult(
                columns: ["affected_rows", "message"],
                rows: [[String(affectedRows), "INSERT 命令执行成功，影响 \(affectedRows) 行"]],
                executionTime: executionTime
            )
        } else if lowerQuery.contains("update") {
            let affectedRows = Int.random(in: 1...10)
            return QueryResult(
                columns: ["affected_rows", "message"],
                rows: [[String(affectedRows), "UPDATE 命令执行成功，影响 \(affectedRows) 行"]],
                executionTime: executionTime
            )
        } else if lowerQuery.contains("delete") {
            let affectedRows = Int.random(in: 1...3)
            return QueryResult(
                columns: ["affected_rows", "message"],
                rows: [[String(affectedRows), "DELETE 命令执行成功，影响 \(affectedRows) 行"]],
                executionTime: executionTime
            )
        } else if lowerQuery.contains("drop") || lowerQuery.contains("truncate") {
            return QueryResult(
                columns: ["status", "message"],
                rows: [["success", "命令执行成功"]],
                executionTime: executionTime
            )
        } else if lowerQuery.contains("create") {
            return QueryResult(
                columns: ["status", "message"],
                rows: [["success", "CREATE 命令执行成功"]],
                executionTime: executionTime
            )
        } else if lowerQuery.contains("alter") {
            return QueryResult(
                columns: ["status", "message"],
                rows: [["success", "ALTER 命令执行成功"]],
                executionTime: executionTime
            )
        } else {
            return QueryResult(
                columns: ["status", "message"],
                rows: [["success", "SQL 命令执行成功"]],
                executionTime: executionTime
            )
        }
    }
}
