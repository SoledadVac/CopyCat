# 运行 CopyCat 项目

## 前提条件

您的电脑上已经安装了 Swift 6.1.2，这很好！

## 方法一：使用 Xcode（推荐）

### 安装 Xcode

如果您没有 Xcode，可以通过以下方式安装：

1. 打开 Mac App Store
2. 搜索 "Xcode"
3. 下载并安装（需要约 10GB 空间）

### 使用 Xcode 运行项目

1. 双击打开 `CopyCat.xcodeproj`
2. 等待 Xcode 索引项目
3. 点击左上角的播放按钮（▶️）或按 `Cmd + R`
4. 应用将自动构建并启动

## 方法二：使用命令行工具（需要 Xcode 命令行工具）

### 检查是否安装了 Xcode 命令行工具

```bash
xcode-select -p
```

如果已安装，会显示路径，如：`/Applications/Xcode.app/Contents/Developer`

### 如果未安装，安装命令行工具：

```bash
xcode-select --install
```

### 使用 xcodebuild 编译

```bash
cd /Users/liuhuichao/JavaProject/CopyCat
xcodebuild -project CopyCat.xcodeproj -scheme CopyCat -configuration Debug
```

### 运行编译后的应用

```bash
open build/Debug/CopyCat.app
```

## 项目结构说明

```
CopyCat/
├── Sources/              # 源代码
│   ├── App/             # 应用入口
│   ├── Core/            # 核心业务逻辑
│   │   ├── Database/    # 数据库管理
│   │   ├── Security/    # 安全加密
│   │   └── Models/      # 数据模型
│   ├── UI/              # SwiftUI 界面
│   │   ├── Components/  # 可复用组件
│   │   └── Scenes/      # 页面视图
│   └── Utilities/       # 工具类
├── Documentation/        # 项目文档
└── Resources/           # 资源文件
```

## 下一步

1. 安装 Xcode（如果还没有）
2. 打开 CopyCat.xcodeproj
3. 运行项目
4. 开始使用！

## 常见问题

**Q: 没有 Xcode 怎么办？**
A: 对于 macOS GUI 应用，Xcode 是必需的开发工具。您可以从 Mac App Store 免费下载。

**Q: 项目构建失败？**
A: 确保您使用的是最新版本的 Xcode，并且 macOS 版本是 15.0 或更高。

**Q: 如何添加新的数据库驱动？**
A: 查看 Sources/Core/Database/ 目录，添加新的数据库连接实现。
