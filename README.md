# Picture2Words - 图像识别英语学习应用

## 项目概述
Picture2Words 是一款创新的语言学习应用，旨在帮助用户通过图像识别和AI技术快速学习英语单词。

### 核心功能
- 拍摄或上传图片
- 使用AI识别图片中的物体
- 自动生成相关英文单词
- 提供单词发音和学习建议

### 学习方法
1. 拍摄日常生活中的物品
2. 应用自动识别并生成英文单词
3. 记忆和学习新单词
4. 逐步扩大词汇量

## 技术栈
- 开发语言：Swift
- 框架：SwiftUI
- 目标平台：iOS
- AI识别：待选择（可能使用 Vision 框架或第三方服务）

## 项目目录结构解析

### 目录说明

1. `picture2words/`
   - 主应用程序目录
   - 包含应用程序的核心代码和资源
   - 重要文件：
     - `picture2wordsApp.swift`：应用程序入口
     - `ContentView.swift`：主界面视图
     - `Assets.xcassets`：存放图片、颜色等资源

2. `picture2wordsTests/`
   - 单元测试目录
   - 用于编写和运行应用程序的代码测试
   - 确保代码逻辑正确
   - 包含 `picture2wordsTests.swift` 测试文件

3. `picture2wordsUITests/`
   - 用户界面测试目录
   - 测试应用程序的用户交互和界面表现
   - 包含 `picture2wordsUITests.swift` 和 `picture2wordsUITestsLaunchTests.swift`

4. `picture2words.xcodeproj/`
   - Xcode 项目配置文件
   - 存储项目设置、构建配置等
   - 不需要手动修改，由 Xcode 管理

5. `Preview Content/`
   - 存放预览相关的资源
   - 帮助在 Xcode 中快速预览界面设计

### 项目基本信息
- 创建日期：2024/12/8
- 开发工具：Xcode 15
- 编程语言：Swift 5.0
- 目标平台：iOS 17.0
- Bundle Identifier: `com.airobus.picture2words`

### 开发笔记
- 项目初始阶段
- 尚未实现具体功能
- 使用 SwiftUI 框架

## 开发进度

### 技术挑战
- [ ] 图像识别算法
- [ ] AI单词生成
- [ ] 用户界面设计
- [ ] 发音功能集成

### 学习目标
- 掌握 Swift 编程
- 了解 iOS 应用开发
- 学习机器学习在语言学习中的应用

## 学习资源
- [Apple Vision 框架](https://developer.apple.com/documentation/vision)
- [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui/)
- [机器学习在语言学习中的应用](https://arxiv.org/list/cs.CL/recent)

## 项目灵感
受到传统语言学习方法的局限，希望通过直观、有趣的方式帮助用户学习英语。 