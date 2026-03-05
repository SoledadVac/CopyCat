import SwiftUI
import UniformTypeIdentifiers

struct DataOperationsView: View {
    let connection: ConnectionConfig
    @StateObject private var viewModel = DataOperationsViewModel()
    @State private var selectedOperation = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("操作", selection: $selectedOperation) {
                Text("导入数据").tag(0)
                Text("导出数据").tag(1)
                Text("备份").tag(2)
                Text("数据生成").tag(3)
            }
            .pickerStyle(.segmented)
            .frame(width: 500)
            .padding()
            
            Divider()
            
            TabView(selection: $selectedOperation) {
                ImportDataView(viewModel: viewModel)
                    .tag(0)
                
                ExportDataView(viewModel: viewModel)
                    .tag(1)
                
                BackupView(viewModel: viewModel)
                    .tag(2)
                
                DataGeneratorView(viewModel: viewModel)
                    .tag(3)
            }
        }
        .onAppear {
            viewModel.connection = connection
        }
    }
}

struct ImportDataView: View {
    @ObservedObject var viewModel: DataOperationsViewModel
    @State private var selectedFileURL: URL?
    @State private var selectedFormat = 0
    
    let formats = ["CSV", "JSON", "SQL", "Excel"]
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("选择文件")
                    .font(.headline)
                
                if let fileURL = selectedFileURL {
                    HStack {
                        Image(systemName: "doc.fill")
                        Text(fileURL.lastPathComponent)
                        Spacer()
                        Button("清除") {
                            selectedFileURL = nil
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                } else {
                    Button(action: selectFile) {
                        Label("选择文件...", systemImage: "folder")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: 500)
            
            VStack(spacing: 12) {
                Text("文件格式")
                    .font(.headline)
                
                Picker("格式", selection: $selectedFormat) {
                    ForEach(0..<formats.count, id: \.self) { index in
                        Text(formats[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 400)
            }
            .frame(maxWidth: 500)
            
            Spacer()
            
            Button(action: { viewModel.importData(fileURL: selectedFileURL, format: formats[selectedFormat]) }) {
                Text("开始导入")
                    .frame(maxWidth: 300)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedFileURL == nil)
        }
        .padding()
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.commaSeparatedText, .json, .data, .spreadsheet]
        
        if panel.runModal() == .OK {
            selectedFileURL = panel.url
        }
    }
}

struct ExportDataView: View {
    @ObservedObject var viewModel: DataOperationsViewModel
    
    var body: some View {
        Text("导出数据 - 功能开发中")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BackupView: View {
    @ObservedObject var viewModel: DataOperationsViewModel
    
    var body: some View {
        Text("备份 - 功能开发中")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DataGeneratorView: View {
    @ObservedObject var viewModel: DataOperationsViewModel
    
    var body: some View {
        Text("数据生成 - 功能开发中")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@MainActor
class DataOperationsViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var progress: Double = 0
    @Published var statusMessage = ""
    var connection: ConnectionConfig?
    
    func importData(fileURL: URL?, format: String) {
        guard let fileURL = fileURL else { return }
        
        isLoading = true
        statusMessage = "正在导入...\(fileURL.lastPathComponent)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.progress = 1.0
            self.statusMessage = "导入完成！"
        }
    }
}
