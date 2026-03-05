import SwiftUI

struct QueryEditorView: View {
    let connection: ConnectionConfig
    let initialQuery: String?
    @StateObject private var viewModel = QueryEditorViewModel()
    @State private var selectedTab = 0
    
    init(connection: ConnectionConfig, initialQuery: String? = nil) {
        self.connection = connection
        self.initialQuery = initialQuery
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("视图", selection: $selectedTab) {
                    Text("查询").tag(0)
                    Text("表").tag(1)
                    Text("数据").tag(2)
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            
            Divider()
            
            if selectedTab == 0 {
                VStack(spacing: 0) {
                    TextEditor(text: $viewModel.queryText)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxHeight: .infinity)
                        .padding(8)
                    
                    Divider()
                    
                    HStack {
                        Button(action: viewModel.clearQuery) {
                            Label("清空", systemImage: "trash")
                        }
                        
                        Button(action: viewModel.formatQuery) {
                            Label("格式化", systemImage: "text.justify")
                        }
                        
                        Spacer()
                        
                        if viewModel.isExecuting {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        
                        SafeButton("执行查询", requiresConfirmation: viewModel.requiresConfirmation) {
                            Task {
                                await viewModel.executeQuery(connection: connection)
                            }
                        }
                        .keyboardShortcut(.return, modifiers: .command)
                    }
                    .padding()
                    
                    Divider()
                    
                    if viewModel.batchQueryResult != nil {
                        BatchQueryResultTable(batchResult: viewModel.batchQueryResult)
                            .padding()
                    } else {
                        QueryResultTable(result: viewModel.queryResult)
                            .padding()
                    }
                }
            } else if selectedTab == 1 {
                TableStructureView(connection: connection, selectedTable: nil)
            } else {
                DataOperationsView(connection: connection)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker("历史记录", selection: $viewModel.selectedHistory) {
                    Text("当前查询").tag(nil as QueryHistory?)
                    ForEach(viewModel.queryHistory, id: \.id) { history in
                        Text(history.query.prefix(50) + "...").tag(history as QueryHistory?)
                    }
                }
                .frame(width: 300)
            }
        }
        .onAppear {
            if let initialQuery = initialQuery {
                viewModel.queryText = initialQuery
            }
        }
        .onChange(of: initialQuery) { _, newQuery in
            if let newQuery = newQuery {
                viewModel.queryText = newQuery
                Task {
                    await viewModel.executeQuery(connection: connection)
                }
            }
        }
    }
}

@MainActor
class QueryEditorViewModel: ObservableObject {
    @Published var queryText = ""
    @Published var queryResult: QueryResult?
    @Published var batchQueryResult: BatchQueryResult?
    @Published var isExecuting = false
    @Published var queryHistory: [QueryHistory] = []
    @Published var selectedHistory: QueryHistory?
    @Published var errorMessage: String?
    
    var requiresConfirmation: Bool {
        let lowerQuery = queryText.lowercased()
        return lowerQuery.contains("drop") || lowerQuery.contains("delete") || lowerQuery.contains("truncate")
    }
    
    func clearQuery() {
        queryText = ""
        queryResult = nil
        batchQueryResult = nil
    }
    
    func formatQuery() {
        queryText = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func executeQuery(connection: ConnectionConfig) async {
        guard !queryText.isEmpty else { return }
        
        isExecuting = true
        errorMessage = nil
        queryResult = nil
        batchQueryResult = nil
        
        defer {
            isExecuting = false
        }
        
        do {
            let executor = QueryExecutor(connection: connection)
            let queries = executor.splitQueries(queryText)
            
            if queries.count == 1 {
                let result = try await executor.execute(queries[0])
                queryResult = result
                
                let history = QueryHistory(
                    connectionId: connection.id,
                    query: queryText,
                    resultCount: result.rows.count,
                    executionTime: result.executionTime,
                    success: true
                )
                queryHistory.insert(history, at: 0)
            } else {
                let batchResult = try await executor.executeBatch(queries)
                batchQueryResult = batchResult
                
                let history = QueryHistory(
                    connectionId: connection.id,
                    query: queryText,
                    resultCount: batchResult.results.count,
                    executionTime: batchResult.totalExecutionTime,
                    success: true
                )
                queryHistory.insert(history, at: 0)
            }
        } catch {
            errorMessage = error.localizedDescription
            Logger.shared.error("查询执行失败: \(error)")
            
            let history = QueryHistory(
                connectionId: connection.id,
                query: queryText,
                success: false,
                errorMessage: error.localizedDescription
            )
            queryHistory.insert(history, at: 0)
        }
    }
}
