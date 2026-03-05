📜 SKILL.md  
macOS 本地数据库管理应用 · 项目规范与初始化准则  Swift + SwiftUI | 专业级桌面应用开发标准 | 最后更新：2026.03.03

🌟 一、项目核心原则
✅ 用户第一：数据库操作零误触（二次确认/撤销机制）  
✅ 安全至上：本地数据永不上传，连接密码AES-256加密存储  
✅ Apple Design：严格遵循 Human Interface Guidelines (macOS Sequoia)  
✅ 渐进增强：基础功能 → 高级功能 → 云同步（分阶段交付）  
✅ 测试驱动：核心模块测试覆盖率 ≥ 80%（XCTest + Snapshot Testing）

🛠️ 二、技术栈规范（锁定版本）
模块   技术选型   版本要求   说明
语言   Swift   6.0+   启用严格并发检查 (-enable-experimental-concurrency)

UI框架   SwiftUI   5.0+   混合AppKit仅限必要场景（见混合开发规范）

数据库驱动   SQLite.swift   0.15.0+   本地SQLite管理；其他库通过Swift Package动态加载

加密   CryptoKit   系统自带   密码存储：PBKDF2-SHA256 + 盐值

依赖管理   Swift Package Manager   Xcode 16+   禁用CocoaPods/Carthage

构建   Xcode Cloud   -   自动化测试 + TestFlight分发

文档   Swift-DocC   -   代码注释自动生成文档

📂 三、项目目录结构（Xcode Group规范）
CopyCat/                 # 项目根目录
├── Sources/
│   ├── App/                   # App主入口
│   │   ├── CopyCatApp.swift
│   │   └── AppDelegate.swift  # 仅处理NSApplicationDelegate必要逻辑
│   ├── Core/                  # 核心业务层（无UI依赖）
│   │   ├── Database/
│   │   │   ├── SQLiteManager.swift      # SQLite连接/查询封装
│   │   │   ├── ConnectionManager.swift  # 连接池管理
│   │   │   └── QueryExecutor.swift      # 安全查询执行（防SQL注入）
│   │   ├── Security/
│   │   │   ├── PasswordVault.swift      # 密码加密存储
│   │   │   └── KeychainHelper.swift
│   │   └── Models/
│   │       ├── ConnectionConfig.swift   # Codable: 连接配置
│   │       └── QueryHistory.swift
│   ├── UI/                    # SwiftUI视图层（严格分层）
│   │   ├── Scenes/            # 页面级视图
│   │   │   ├── DashboardView.swift
│   │   │   ├── QueryEditorView.swift
│   │   │   └── ConnectionManagerView.swift
│   │   ├── Components/        # 可复用组件
│   │   │   ├── SafeButton.swift         # 带防抖/权限校验的按钮
│   │   │   ├── QueryResultTable.swift   # 表格结果渲染
│   │   │   └── ConnectionCard.swift
│   │   └── Resources/         # 资源文件
│   │       ├── Assets.xcassets
│   │       └── Localizable.strings      # 多语言（首期支持en/zh-Hans）
│   └── Utilities/             # 工具类
│       ├── Logger.swift       # 统一日志（OSLog）
│       ├── ErrorHandling.swift
│       └── Extensions/        # 扩展分类
│           ├── String+Validation.swift
│           └── Color+Theme.swift
├── Tests/
│   ├── UnitTests/             # 单元测试（Core层）
│   ├── UITests/               # UI测试（关键路径）
│   └── SnapshotTests/         # SwiftUI快照测试（SwiftSnapshotTesting）
├── Resources/                 # 非代码资源
│   ├── PrivacyInfo.xcprivacy  # 隐私清单（App Store审核必需）
│   └── entitlements.plist     # 沙盒权限配置
└── Documentation/             # 项目文档
    ├── ARCHITECTURE.md        # 架构设计图
    ├── SECURITY.md            # 安全规范
    └── RELEASE_NOTES.md

🎨 四、SwiftUI 专项规范
✅ 必须遵守
// 1. 视图纯函数化
struct QueryEditorView: View {
    let viewModel: QueryEditorViewModel // 仅接收ViewModel，不持有业务逻辑
    var body: some View { ... }
}

// 2. 状态管理分层
@MainActor class QueryEditorViewModel: ObservableObject {
    @Published private(set) var queryText = ""
    @Published private(set) var results: [Row] = []
    // 业务逻辑封装在ViewModel，View仅绑定状态
}

// 3. 安全操作防护
SafeButton("执行删除", role: .destructive) {
    confirmDeletion() // 触发系统级确认弹窗
}
.destructiveActionProtection() // 自定义修饰符：高危操作二次确认

// 4. 暗黑模式适配
Color("PrimaryButton") // 从Assets.xcassets取色，非硬编码

❌ 严禁行为
在View中直接写数据库操作逻辑  
使用@State管理跨视图共享状态（用@EnvironmentObject）  
硬编码颜色/字体（统一用Asset Catalog）  
忽略@MainActor导致UI线程崩溃  

🔒 五、安全与隐私强制规范
场景   实现方案   验证方式
连接密码存储   Keychain + PBKDF2加密   单元测试验证加密/解密

SQL注入防护   参数化查询（SQLite.swift绑定）   模糊测试注入攻击字符串

沙盒权限   仅开启com.apple.security.files.user-selected.read-write   Xcode沙盒测试报告

隐私清单   PrivacyInfo.xcprivacy声明数据用途   App Store Connect预检

崩溃日志   本地存储（不上传第三方）   审计日志脱敏处理

📌 红线：任何涉及用户数据的操作必须通过SecurityAudit模块记录（时间/操作类型/目标库）

🧪 六、测试规范
// 单元测试示例（Tests/UnitTests/Database/QueryExecutorTests.swift）
final class QueryExecutorTests: XCTestCase {
    func test_safeQuery_preventsSQLInjection() throws {
        let executor = QueryExecutor(db: mockDB)
        let result = try executor.execute(
            "SELECT * FROM users WHERE id = ?", 
            parameters: ["1; DROP TABLE users--"]
        )
        XCTAssertFalse(result.contains("DROP")) // 验证注入被拦截
    }
}

// 快照测试（Tests/SnapshotTests/UI/QueryResultTableSnapshotTests.swift）
func test_queryResultTable_rendering() {
    let view = QueryResultTable(results: sampleData)
    assertSnapshot(matching: view, as: .image)
}

覆盖率要求：Core层 ≥ 80%，UI层关键路径100%  
CI门禁：Xcode Cloud构建失败/测试未通过 → 阻断合并  

📦 七、构建与发布流程
graph LR
    A[Feature Branch] --> B{PR Review}
    B -->|通过| C[Xcode Cloud 自动构建]
    C --> D[运行测试套件]
    D -->|通过| E[TestFlight 内部测试]
    E --> F[收集反馈/修复]
    F --> G[App Store Connect 提交]
    G --> H[人工审核]
    H --> I[正式发布]

版本号规则：主版本.功能版本.修复版本（例：1.2.0）  
发布清单：  
  ✅ 更新RELEASE_NOTES.md  
  ✅ 生成Swift-DocC文档  
  ✅ 隐私清单合规检查  
  ✅ 沙盒权限最终验证  

🌍 八、国际化与无障碍
要求   实现
多语言   Localizable.strings + NSLocalizedString

动态字体   .font(.body) + @Environment(.sizeCategory)

VoiceOver   为关键按钮添加accessibilityLabel/accessibilityHint

色彩对比   使用Xcode无障碍检查器验证（对比度≥4.5:1）

🤝 九、贡献流程
Fork → Feature Branch（命名：feat/xxx 或 fix/xxx）  
提交规范：  
      feat(ui): 添加查询历史撤销功能
   fix(security): 修复密码存储盐值生成漏洞
   docs: 更新SKILL.md安全章节
   
PR要求：  
   关联Issue编号  
   包含测试代码 + 截图（UI变更）  
   通过所有CI检查  
Code Review重点：  
   安全漏洞  
   SwiftUI状态管理合理性  
   是否符合HIG设计规范  

📌 十、初始化检查清单（项目启动必做）
[ ] 创建Xcode项目（macOS App，SwiftUI + AppKit）  
[ ] 配置Swift Package依赖（SQLite.swift等）  
[ ] 生成PrivacyInfo.xcprivacy并声明数据用途  
[ ] 设置沙盒权限（仅用户选择文件）  
[ ] 初始化Git + .gitignore（含DerivedData）  
[ ] 创建SKILL.md + ARCHITECTURE.md  
[ ] 配置Xcode Cloud（连接GitHub）  
[ ] 添加基础测试框架（XCTest + SnapshotTesting）  
[ ] 设置SwiftLint（.swiftlint.yml）  
[ ] 创建首版RELEASE_NOTES.md（v0.1.0）  

💡 附录：关键资源
资源   链接
Apple HIG (macOS)   https://developer.apple.com/design/human-interface-guidelines/macos

Swift 并发指南   https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency

沙盒调试技巧   https://developer.apple.com/documentation/xcode/fixing-sandbox-errors

SwiftLint规则集   https://realm.github.io/SwiftLint/rule-directory.html

无障碍测试   Xcode → Product → Scheme → Edit Scheme → Options → Accessibility


