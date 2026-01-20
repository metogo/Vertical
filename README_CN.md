# Vertical - 城市攀登者追踪器

Vertical 是一款高性能、沉浸式的楼梯攀登追踪应用，专为城市探险者设计。采用 **SwiftUI**、**The Composable Architecture (TCA)** 和 **Metal** 构建，将你的摩天大楼攀登和城市探险转化为一场视觉盛宴。

## 🚀 核心功能

- **实时 VAM 抬头显示**：利用 iPhone 气压计高精度追踪你的每小时攀升米数（VAM）。
- **Metal 可视化**：动态 3D 粒子系统和螺旋轨迹渲染器，实时可视化你的攀登过程。
- **地标发现**：当你达到相应高度时，解锁著名的高海拔建筑，如自由女神像或哈利法塔。
- **隐私优先分享**：生成电影级分享卡片，自动裁剪 GPS/海拔数据以隐藏起点和终点位置。
- **CloudKit 同步**：你的攀登记录会自动同步到所有 iCloud 设备。
- **原生体验**：集成触感反馈、后台位置保护和本地通知。

## 🛠 技术栈

- **架构**：The Composable Architecture (TCA)
- **数据库**：GRDB (SQLite)
- **图形**：Metal（自定义着色器）
- **传感器**：CoreMotion（气压计）、CoreLocation（后台位置保护）
- **云服务**：CloudKit
- **界面**：SwiftUI（霓虹暗黑美学）

## 📁 项目结构

- `Vertical/Sources/Features`：基于组件的功能模块（追踪器、时间线、结果、引导页）
- `Vertical/Sources/Rendering`：Metal 着色器和渲染逻辑
- `Vertical/Sources/Clients`：依赖注入的客户端（传感器、数据库、CloudKit）
- `Vertical/Sources/Database`：数据模型和持久化层

## 🚦 快速开始

1. 在 Xcode 15+ 中打开 `Vertical/Vertical.xcodeproj`。
2. 建议使用真机 iPhone 以获得最佳体验（需要气压计传感器）。
3. 编译并运行到你的设备上。
4. 同意安全免责声明后即可开始你的第一次攀登。

## 🎮 模拟器演示模式

在模拟器中运行时，应用会自动切换到**演示模式**：

- 模拟每秒 1.5 米的攀升速度
- 可以完整体验 UI 动画和粒子效果
- 数据库操作被跳过以避免 Actor 隔离问题

## 🌍 国际化

应用支持以下语言：

- 🇺🇸 English（英语）
- 🇨🇳 简体中文

## 🛡 免责声明

楼梯攀登是一项高强度运动。请确保你身体健康，并时刻注意周围环境。Vertical 仅用于追踪目的。

---

_由 Fanhua 和 Antigravity 创建 (2026)_
