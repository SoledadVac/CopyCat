import SwiftUI

struct DatabaseExplorerView: View {
    let connection: ConnectionConfig
    @StateObject private var viewModel = DatabaseExplorerViewModel()
    @Binding var selectedTable: String?
    var onTableDoubleClick: ((String) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("数据库")
                    .font(.headline)
                Spacer()
                Button(action: viewModel.refresh) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
            }
            .padding()
            
            Divider()
            
            List {
                ForEach(viewModel.databases, id: \.self) { database in
                    let isExpandedBinding = Binding<Bool>(
                        get: {
                            viewModel.expandedDatabases[database, default: true]
                        },
                        set: { newValue in
                            viewModel.expandedDatabases[database] = newValue
                        }
                    )
                    
                    DatabaseSection(
                        database: database,
                        tables: viewModel.tables[database] ?? [],
                        selectedTable: $selectedTable,
                        isExpanded: isExpandedBinding,
                        onTableDoubleClick: onTableDoubleClick
                    )
                }
            }
            .listStyle(.sidebar)
        }
        .onAppear {
            viewModel.connection = connection
            viewModel.refresh()
        }
    }
}

struct DatabaseSection: View {
    let database: String
    let tables: [String]
    @Binding var selectedTable: String?
    @Binding var isExpanded: Bool
    var onTableDoubleClick: ((String) -> Void)?
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(tables, id: \.self) { table in
                HStack {
                    Image(systemName: "tablecells")
                        .foregroundColor(.secondary)
                    Text(table)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTable = table
                }
                .onTapGesture(count: 2) {
                    onTableDoubleClick?(table)
                }
                .background(selectedTable == table ? Color.accentColor.opacity(0.2) : Color.clear)
                .cornerRadius(4)
            }
        } label: {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
                Text(database)
                Spacer()
            }
        }
    }
}

@MainActor
class DatabaseExplorerViewModel: ObservableObject {
    @Published var databases: [String] = []
    @Published var tables: [String: [String]] = [:]
    @Published var expandedDatabases: [String: Bool] = [:]
    @Published var isLoading = false
    var connection: ConnectionConfig?
    
    func refresh() {
        isLoading = true
        defer { isLoading = false }
        
        guard let connection = connection else { return }
        
        if let database = connection.database {
            databases = [database]
            tables[database] = ["users", "products", "orders"]
            expandedDatabases[database] = true
        } else {
            databases = ["information_schema", "mysql", "performance_schema"]
            for db in databases {
                tables[db] = []
                expandedDatabases[db] = true
            }
        }
    }
}
