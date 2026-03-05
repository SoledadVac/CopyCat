import SwiftUI

struct TableStructureView: View {
    let connection: ConnectionConfig
    let selectedTable: String?
    @StateObject private var viewModel = TableStructureViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if let displayTable = viewModel.selectedTable ?? selectedTable {
                VStack(spacing: 0) {
                    HStack {
                        Text(displayTable)
                            .font(.headline)
                        Spacer()
                        Button(action: { viewModel.refreshTableStructure() }) {
                            Label("刷新", systemImage: "arrow.clockwise")
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("字段")
                                    .font(.headline)
                                
                                VStack(spacing: 0) {
                                    HStack {
                                        Text("名称")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("类型")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("允许空")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("键")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("默认值")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    
                                    Divider()
                                    
                                    ForEach(viewModel.columns) { column in
                                        HStack {
                                            Text(column.name)
                                                .font(.body)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text(column.type)
                                                .font(.body)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text(column.nullable ? "是" : "否")
                                                .font(.body)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text(column.key)
                                                .font(.body)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text(column.defaultValue ?? "")
                                                .font(.body)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        
                                        Divider()
                                    }
                                }
                                .border(Color(NSColor.separatorColor), width: 1)
                                .cornerRadius(4)
                            }
                            .padding()
                        }
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "tablecells")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("从侧边栏选择一个表以查看结构")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.connection = connection
            viewModel.refreshTables()
        }
        .onChange(of: selectedTable) { _, newTable in
            if let newTable = newTable {
                viewModel.selectedTable = newTable
            }
        }
    }
}

struct DBTableColumn: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let nullable: Bool
    let key: String
    let defaultValue: String?
}

@MainActor
class TableStructureViewModel: ObservableObject {
    @Published var tables: [String] = []
    @Published var selectedTable: String? {
        didSet {
            refreshTableStructure()
        }
    }
    @Published var columns: [DBTableColumn] = []
    @Published var isLoading = false
    var connection: ConnectionConfig?
    
    func refreshTables() {
        isLoading = true
        defer { isLoading = false }
        
        tables = ["users", "products", "orders"]
    }
    
    func refreshTableStructure() {
        guard let _ = selectedTable else { return }
        columns = [
            DBTableColumn(name: "id", type: "INT", nullable: false, key: "PRI", defaultValue: nil),
            DBTableColumn(name: "name", type: "VARCHAR(255)", nullable: false, key: "", defaultValue: nil),
            DBTableColumn(name: "created_at", type: "DATETIME", nullable: true, key: "", defaultValue: "CURRENT_TIMESTAMP")
        ]
    }
}
