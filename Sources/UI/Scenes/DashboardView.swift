import SwiftUI

struct DashboardView: View {
    let connection: ConnectionConfig
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTab = 0
    @State private var selectedTable: String?
    
    var body: some View {
        HSplitView {
            DatabaseExplorerView(connection: connection, selectedTable: $selectedTable)
                .frame(minWidth: 200, idealWidth: 280)
            
            VStack(spacing: 0) {
                HStack {
                    Picker("视图", selection: $selectedTab) {
                        Text("查询编辑器").tag(0)
                        Text("表结构").tag(1)
                        Text("数据操作").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 400)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if let lastConnected = connection.lastConnectedAt {
                            Text("已连接 • \(formatDate(lastConnected))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding()
                
                Divider()
                
                TabView(selection: $selectedTab) {
                    QueryEditorView(connection: connection)
                        .tag(0)
                        .tabItem {
                            Label("查询", systemImage: "text.append")
                        }
                    
                    TableStructureView(connection: connection, selectedTable: selectedTable)
                        .tag(1)
                        .tabItem {
                            Label("表", systemImage: "tablecells")
                        }
                    
                    DataOperationsView(connection: connection)
                        .tag(2)
                        .tabItem {
                            Label("数据", systemImage: "square.and.arrow.up")
                        }
                }
            }
        }
        .navigationTitle(connection.name)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
}
