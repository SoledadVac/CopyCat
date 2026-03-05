# CopyCat

专业的 macOS 本地数据库管理应用，基于 Swift + SwiftUI 构建。

## 功能特性

### 多数据库支持
- MySQL / MariaDB
- PostgreSQL
- SQL Server
- Oracle
- SQLite
- MongoDB
- Redis

### 核心功能
- 🔗 连接管理（支持 SSH/SSL 隧道）
- 📊 查询编辑器（带历史记录）
- 🗄️ 表结构可视化
- 📥 数据导入导出
- 🔒 密码安全存储（Keychain + AES-256）
- 🎨 macOS 原生设计

## 系统要求

- macOS 15.0 (Sequoia) 或更高版本
- Xcode 16.0 或更高版本
- Swift 6.0 或更高版本

## 安装

### 使用 Xcode

1. 克隆项目
2. 打开 `CopyCat.xcodeproj`
3. 构建并运行

### 使用 Swift Package Manager

```bash
swift build
swift run
```

## 项目结构

```
CopyCat/
├── Sources/
│   ├── App/              # 应用主入口
│   ├── Core/             # 核心业务层
│   │   ├── Database/     # 数据库管理
│   │   ├── Security/     # 安全加密
│   │   └── Models/       # 数据模型
│   ├── UI/               # SwiftUI 视图
│   │   ├── Scenes/       # 页面视图
│   │   ├── Components/   # 可复用组件
│   │   └── Resources/    # 资源文件
│   └── Utilities/        # 工具类
├── Tests/                # 测试代码
├── Resources/            # 非代码资源
└── Documentation/        # 项目文档
```

## 开发

### 构建项目

```bash
swift build
```

### 运行测试

```bash
swift test
```

## 文档

- [架构设计](Documentation/ARCHITECTURE.md)
- [安全规范](Documentation/SECURITY.md)
- [发布说明](Documentation/RELEASE_NOTES.md)

## 许可证

MIT License
