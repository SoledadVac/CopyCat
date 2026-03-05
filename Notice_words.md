# Notice Words

本文件用于记录每次编写的提示词。

---

## 2026-03-03

1. 下载我的项目：git@github.com:SoledadVac/CopyCat.git到本地
2. 先取消下载吧
3. 需要这个license,帮我在项目下面创建Notice_words.md文件，用于记录我每次编写的提示词
4. 根目录添加SKILL.md
5. 我刚手动为项目添加了SKILL.md文件，每次将我们对话的提示词帮我自动保存到Notice_words.md文件
6. 加载根目录的SKILL.md文件
7. 我在根目录上添加了一个初始需求.md的文档，定了了项目的核心功能需求，请根据这个需求文档生成macos版本的数据库管理软件，要求根目录下面的所有文件操作无需询问，可根据模型规划自动执行
8. 怎么运行项目，我电脑上没有xcode
9. Terminal#12-15 执行更新
10. xcode安装完成，运行一下项目
11. 出现错误：/Users/liuhuichao/JavaProject/CopyCat/Sources/Core/Database/ConnectionManager.swift:76:36 Sending 'self' risks causing data races
12. 修复下出现的错误：/Users/liuhuichao/JavaProject/CopyCat/Sources/UI/Scenes/DataOperationsView.swift:109:67 Type 'Array<UTType>.ArrayLiteralElement' (aka 'UTType') has no member 'sql'
13. 先编译下项目，如果有编译问题，修复下编译的问题
14. 存在编译问题：/Users/liuhuichao/JavaProject/CopyCat/Sources/UI/Scenes/ConnectionFormView.swift:193:21 Cannot assign to property: 'id' is a 'let' constant
15. 项目启动运行之后，没有出现任何页面
16. 修复下新出现的编译问题：/Users/liuhuichao/JavaProject/CopyCat/Sources/App/CopyCatApp.swift:16:10 Value of type 'WindowGroup<some View>' has no member 'windowTitle'
17. 运行之后没有出现任何界面，再修复下，修复完成之后整体编译下项目
18. 运行之后没有弹出任何窗口，再修复下
19. 出现编译失败的错误：/Users/liuhuichao/JavaProject/CopyCat/Sources/App/CopyCatApp.swift:37:35 Member 'tertiary' in 'Color?' produces result of type 'some ShapeStyle', but context expects 'Color?'，修复下
20. 运行之后没有弹出任何窗口，再修复下
21. 看到启动窗口了，正常恢复功能
22. build failed,error message:/Users/liuhuichao/JavaProject/CopyCat/Sources/App/CopyCatApp.swift:6:9 Main actor-isolated default value in a nonisolated context,fix it
23. 为我的本地安装一个mysql服务，设置用户名密码为root,root
24. 添加功能，数据源添加成功之后，以自动展开显示数据源下面的数据库
25. build failed,出现：/Users/liuhuichao/JavaProject/CopyCat/Sources/UI/Scenes/DashboardView.swift:48:79 Cannot convert value of type 'Binding<String?>' to expected argument type 'String' ，修复下这个问题，修复完成之后再编译下
26. 出现错误：/Users/liuhuichao/JavaProject/CopyCat/Sources/UI/Scenes/DatabaseExplorerView.swift:28:65 Subscript index of type '() -> Bool' in a key path must be Hashable，修复这个问题
27. 连接之后显示数据库表，显示在连接的下方，页面布局上，布局比例做成上图所示，查询输入框占据右侧大部分，方便进行sql编写
28. 双击表名称，默认分页查询表的10条数据展示在右侧；输入sql语句点击执行查询，执行输入框中的多条sql语句，并在下面展示出每条语句的执行结果
29. 双击表名称，没有触发表数据的默认查询操作；自己在sql查询框里面输入sql语句执行之后没有查询出数据；修复下功能问题
30. 执行sql之后显示sql的执行结果，如果是查询到数据以表格方式显示数据，如果是有影响行数，返回影响行数，如果是报错打印出来详细的报错信息；
31. 把这部分放到对应的连接下面显示，点击连接展开连接下面的库表信息
32. 这个高度再降低一些，降低到目前的一半；右侧执行show tables下方显示的结果不对；修复下这两个问题
33. 把左侧默认宽度调整成上图比例
34. 执行建库语句执行成功，但是查询没有看到该库，修复这个问题；新增功能：1，在数据库上添加右键操作，点击右键，菜单里面有刷新按钮，点击可以重新加载该库下面的表；2，在数据源连接上右键点击添加刷新连接操作，点击刷新连接，可以重新获取该连接下面的库表结构；
