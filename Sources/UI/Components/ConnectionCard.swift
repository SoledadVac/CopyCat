import SwiftUI

struct ConnectionCard: View {
    let connection: ConnectionConfig
    let isSelected: Bool
    let isExpanded: Bool
    let onSelect: () -> Void
    let onToggleExpand: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onTableDoubleClick: ((String) -> Void)?
    
    @StateObject private var viewModel = ConnectionCardViewModel()
    @State private var treeRefreshId = UUID()
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                onSelect()
                onToggleExpand()
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: iconName)
                            .foregroundColor(.accentColor)
                            .font(.caption)
                        Text(connection.name)
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Circle()
                            .fill(connectionColor)
                            .frame(width: 8, height: 8)
                    }
                    
                    HStack {
                        Text(connection.type.displayName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        if let host = connection.host {
                            Text("• \(host)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
                .contextMenu {
                    Button(action: onEdit) {
                        Label("编辑", systemImage: "pencil")
                    }
                    Button(action: {
                        treeRefreshId = UUID()
                    }) {
                        Label("刷新连接", systemImage: "arrow.clockwise")
                    }
                    Divider()
                    Button(role: .destructive, action: onDelete) {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded && isSelected {
                Divider()
                    .padding(.horizontal, 8)
                
                DatabaseTreeView(
                    connection: connection,
                    onRefreshDatabase: { _ in },
                    onTableDoubleClick: onTableDoubleClick
                )
                .id(treeRefreshId)
                .padding(.top, 8)
            }
        }
        .onAppear {
            viewModel.connection = connection
            viewModel.refresh()
        }
    }
    
    private var iconName: String {
        switch connection.type {
        case .sqlite: return "doc.fill"
        case .mysql, .mariadb: return "server.rack"
        case .postgresql: return "database.fill"
        case .mongodb: return "leaf.fill"
        case .redis: return "cube.fill"
        default: return "cylinder.fill"
        }
    }
    
    private var connectionColor: Color {
        guard let colorTag = connection.colorTag else {
            return .gray
        }
        return Color(hex: colorTag) ?? .gray
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct DatabaseTreeView: View {
    let connection: ConnectionConfig
    let onRefreshDatabase: ((String) -> Void)?
    let onTableDoubleClick: ((String) -> Void)?
    @StateObject private var viewModel = DatabaseTreeViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(viewModel.databases, id: \.self) { database in
                DatabaseNode(
                    database: database,
                    tables: viewModel.tables[database] ?? [],
                    onRefreshDatabase: {
                        viewModel.refreshDatabase(database)
                        onRefreshDatabase?(database)
                    },
                    onTableDoubleClick: onTableDoubleClick
                )
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            viewModel.connection = connection
            viewModel.refresh()
        }
    }
}

struct DatabaseNode: View {
    let database: String
    let tables: [String]
    let onRefreshDatabase: (() -> Void)?
    let onTableDoubleClick: ((String) -> Void)?
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { isExpanded.toggle() }) {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(database)
                        .font(.subheadline)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .contextMenu {
                if let onRefreshDatabase = onRefreshDatabase {
                    Button(action: onRefreshDatabase) {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                }
            }
            
            if isExpanded {
                ForEach(tables, id: \.self) { table in
                    HStack(spacing: 8) {
                        Image(systemName: "tablecells")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .frame(width: 16)
                        Text(table)
                            .font(.caption)
                        Spacer()
                    }
                    .padding(.leading, 24)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        onTableDoubleClick?(table)
                    }
                }
            }
        }
    }
}

@MainActor
class ConnectionCardViewModel: ObservableObject {
    var connection: ConnectionConfig?
    
    func refresh() {
    }
}

@MainActor
class DatabaseTreeViewModel: ObservableObject {
    @Published var databases: [String] = []
    @Published var tables: [String: [String]] = [:]
    var connection: ConnectionConfig?
    private var refreshCount = 0
    
    func refresh() {
        guard let connection = connection else { return }
        refreshCount += 1
        
        if let database = connection.database {
            databases = [database]
            tables[database] = ["users", "products", "orders"]
        } else {
            var baseDatabases = ["information_schema", "mysql", "performance_schema"]
            if refreshCount > 1 {
                baseDatabases.append("test1")
            }
            databases = baseDatabases
            for db in databases {
                if db == "test1" {
                    tables[db] = ["new_table1", "new_table2"]
                } else {
                    tables[db] = []
                }
            }
        }
    }
    
    func refreshDatabase(_ database: String) {
        tables[database] = ["users", "products", "orders", "categories", "customers"]
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
