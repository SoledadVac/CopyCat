import SwiftUI

struct ConnectionFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var connectionManager: ConnectionManager
    
    let connection: ConnectionConfig?
    @State private var name: String
    @State private var type: DatabaseType
    @State private var host: String
    @State private var port: String
    @State private var username: String
    @State private var password: String
    @State private var database: String
    @State private var filePath: String
    @State private var useSSL: Bool
    @State private var useSSH: Bool
    @State private var sshHost: String
    @State private var sshPort: String
    @State private var sshUsername: String
    @State private var colorTag: String
    @State private var groupName: String
    @State private var isTesting = false
    @State private var testResult: Bool?
    @State private var errorMessage: String?
    @State private var showingFilePicker = false
    
    private let colorTags = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F"]
    
    init(connection: ConnectionConfig?) {
        self.connection = connection
        _name = State(initialValue: connection?.name ?? "")
        _type = State(initialValue: connection?.type ?? .sqlite)
        _host = State(initialValue: connection?.host ?? "")
        _port = State(initialValue: connection?.port.map(String.init) ?? "")
        _username = State(initialValue: connection?.username ?? "")
        _password = State(initialValue: "")
        _database = State(initialValue: connection?.database ?? "")
        _filePath = State(initialValue: connection?.filePath ?? "")
        _useSSL = State(initialValue: connection?.useSSL ?? false)
        _useSSH = State(initialValue: connection?.useSSH ?? false)
        _sshHost = State(initialValue: connection?.sshHost ?? "")
        _sshPort = State(initialValue: connection?.sshPort.map(String.init) ?? "")
        _sshUsername = State(initialValue: connection?.sshUsername ?? "")
        _colorTag = State(initialValue: connection?.colorTag ?? colorTags.first!)
        _groupName = State(initialValue: connection?.groupName ?? "")
    }
    
    var body: some View {
        Form {
            Section(header: Text("基本信息")) {
                TextField("连接名称", text: $name)
                
                Picker("数据库类型", selection: $type) {
                    ForEach(DatabaseType.allCases) { dbType in
                        Text(dbType.displayName).tag(dbType)
                    }
                }
                
                HStack {
                    Text("颜色标签")
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(colorTags, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? .gray)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(colorTag == color ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    colorTag = color
                                }
                        }
                    }
                }
                
                TextField("分组", text: $groupName)
            }
            
            if type != .sqlite {
                Section(header: Text("连接信息")) {
                    TextField("主机", text: $host)
                    TextField("端口", text: $port)
                    TextField("用户名", text: $username)
                    SecureField("密码", text: $password)
                    TextField("数据库", text: $database)
                    Toggle("使用 SSL", isOn: $useSSL)
                }
                
                Section(header: Text("SSH 隧道")) {
                    Toggle("使用 SSH", isOn: $useSSH)
                    
                    if useSSH {
                        TextField("SSH 主机", text: $sshHost)
                        TextField("SSH 端口", text: $sshPort)
                        TextField("SSH 用户名", text: $sshUsername)
                    }
                }
            } else {
                Section(header: Text("SQLite 文件")) {
                    HStack {
                        TextField("文件路径", text: $filePath)
                        Button("选择文件...") {
                            showingFilePicker = true
                        }
                    }
                }
            }
            
            Section {
                HStack {
                    Button("测试连接") {
                        testConnection()
                    }
                    .disabled(isTesting || name.isEmpty)
                    
                    if isTesting {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    if let result = testResult {
                        Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(result ? .green : .red)
                        Text(result ? "连接成功" : "连接失败")
                            .foregroundColor(result ? .green : .red)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 500)
        .navigationTitle(connection == nil ? "新建连接" : "编辑连接")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(connection == nil ? "创建" : "保存") {
                    saveConnection()
                }
                .disabled(name.isEmpty)
            }
        }
        .alert("错误", isPresented: .constant(errorMessage != nil)) {
            Button("确定") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                filePath = url.path
            }
        }
    }
    
    private func testConnection() {
        Task {
            isTesting = true
            testResult = nil
            
            let config = buildConnectionConfig()
            
            do {
                let result = try await connectionManager.testConnection(config)
                await MainActor.run {
                    testResult = result
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = false
                    isTesting = false
                }
            }
        }
    }
    
    private func saveConnection() {
        let config = buildConnectionConfig()
        
        if let existing = connection {
            var updated = config
            connectionManager.updateConnection(updated)
        } else {
            connectionManager.addConnection(config)
        }
        
        if !password.isEmpty {
            try? PasswordVault.shared.savePassword(password, for: config.id)
        }
        
        if connection == nil {
            Task {
                do {
                    try await connectionManager.connect(to: config)
                } catch {
                    Logger.shared.error("自动连接失败: \(error)")
                }
            }
        }
        
        dismiss()
    }
    
    private func buildConnectionConfig() -> ConnectionConfig {
        if let existing = connection {
            return ConnectionConfig(
                id: existing.id,
                name: name,
                type: type,
                host: type == .sqlite ? nil : host.isEmpty ? nil : host,
                port: type == .sqlite ? nil : Int(port),
                username: type == .sqlite ? nil : username.isEmpty ? nil : username,
                database: type == .sqlite ? nil : database.isEmpty ? nil : database,
                filePath: type == .sqlite ? (filePath.isEmpty ? nil : filePath) : nil,
                useSSL: useSSL,
                useSSH: useSSH,
                sshHost: useSSH ? (sshHost.isEmpty ? nil : sshHost) : nil,
                sshPort: useSSH ? Int(sshPort) : nil,
                sshUsername: useSSH ? (sshUsername.isEmpty ? nil : sshUsername) : nil,
                colorTag: colorTag,
                groupName: groupName.isEmpty ? nil : groupName,
                createdAt: existing.createdAt,
                lastConnectedAt: existing.lastConnectedAt
            )
        } else {
            return ConnectionConfig(
                name: name,
                type: type,
                host: type == .sqlite ? nil : host.isEmpty ? nil : host,
                port: type == .sqlite ? nil : Int(port),
                username: type == .sqlite ? nil : username.isEmpty ? nil : username,
                database: type == .sqlite ? nil : database.isEmpty ? nil : database,
                filePath: type == .sqlite ? (filePath.isEmpty ? nil : filePath) : nil,
                useSSL: useSSL,
                useSSH: useSSH,
                sshHost: useSSH ? (sshHost.isEmpty ? nil : sshHost) : nil,
                sshPort: useSSH ? Int(sshPort) : nil,
                sshUsername: useSSH ? (sshUsername.isEmpty ? nil : sshUsername) : nil,
                colorTag: colorTag,
                groupName: groupName.isEmpty ? nil : groupName
            )
        }
    }
}
