---
workflowType: "prd"
workflow: "edit"
classification:
  projectType: mobile_app
  domain: sport_fitness
  complexity: medium
  projectContext: greenfield
inputDocuments: []
stepsCompleted:
  - step-e-01-discovery
  - step-e-02-review
  - step-e-03-edit
lastEdited: "2026-01-19"
editHistory:
  - date: "2026-01-19"
    changes: "Added internationalization (i18n) requirements for Chinese and English support."
---

# Product Requirements Document - Vertical

**Author:** Fanhua
**Date:** 2026-01-17

## Executive Summary

Vertical 是一款专注于爬楼梯/垂直攀升的运动 App，结合极致的数据美学与 3D 可视化能力。它利用气压计与 AI 算法精准记录垂直运动数据，通过“垂直时空轴”和“3D 螺旋轨迹”将枯燥的爬楼转化为具有成就感的云端攀登体验，服务于高效减脂者、城市碎片化健身白领及专业垂直跑者。

## Project Classification

- **Project Type:** Mobile App
- **Domain:** Sport / Fitness / Health
- **Complexity:** Medium
- **Context:** Greenfield

## Success Criteria

### User Success

- **成就感 (Sense of Achievement)**: 用户通过“垂直时空轴”和解锁 3D 地标（如埃菲尔铁塔），感受到运动的史诗感，消除枯燥。
- **减脂效率 (Efficiency)**: 用户能够直观看到 VAM (垂直升速) 和热量消耗，认可爬楼作为高效减脂方式的价值。
- **社交满足 (Social Satisfaction)**: 生成的高冷、硬核 3D 螺旋轨迹分享卡片被用户主动分享至社交媒体，展示独特运动品味。

### Business Success

- **用户增长 (User Growth)**: 早期依靠 3D 轨迹图的社交裂变实现自然增长。
- **留存率 (Retention)**: 目标用户（如城市白领）形成每周 2-3 次的稳定爬楼习惯。

### Technical Success

- **数据精准度 (Accuracy)**: 高度记录误差 < 5%，算法能精准识别并剔除电梯升降与下楼数据。
- **可视化性能 (Performance)**: 3D 螺旋粒子流与地标模型在主流机型上渲染流畅（60fps），无明显发热耗电。

### Measurable Outcomes

- **核心指标**: 垂直高度记录误差 < 5%。
- **分享率**: > 20% 的完成运动用户生成并分享轨迹图。

## Product Scope

### MVP - Minimum Viable Product

- **核心记录**: 气压计高度融合算法，实时显示高度、层数、VAM。
- **主界面**: 垂直时空轴设计，动态粒子流背景。
- **核心地标**: 首发内置 3-5 个经典地标（如圣彼得大教堂、自由女神像、埃菲尔铁塔）。
- **分享**: 基于 GPS 聚簇点的 3D 螺旋轨迹生成与分享卡片。
- **国际化支持**: 应用界面、语音播报及推送支持中英文切换。
- **基础设置**: 楼层高度校准及语言偏好设置。

### Growth Features (Post-MVP)

- **社交排行**: 好友间的垂直高度排行榜。
- **更多地标**: 扩展全球著名高层建筑地标包。
- **可穿戴支持**: 独立 Apple Watch 应用。
- **AR 体验**: 基于地理位置的实景 AR 打卡。

### Vision (Future)

- 打造全球最大的垂直运动数据库与社区，定义“垂直跑”运动标准。

## User Journeys

### 1. Liam - 高效减脂者 (Primary User - Success Path)

**Story**: 28岁广告人，追求“短平快”的高强度训练。
**The Journey**:

1.  **开场**: 晚上加完班，Liam 跳过电梯，打开 Vertical。主界面的垂直中轴线微弱脉冲，激发了他的挑战欲。点击“向上”开始。
2.  **攀爬**: 爬到 10 楼，TTS 语音播报（根据设定的语言，如 "10 Floors, VAM 1200" 或 "10层，垂直升速 1200"），激励他保持速度。
3.  **高潮**: 20 楼力竭时，看到屏幕上荧光粒子流速加快，3D 螺旋线缠绕在“虚拟圣彼得大教堂”塔尖，提示“还有 30 米登顶”。这种视觉化的目标感让他咬牙冲刺。
4.  **结局**: 25 楼结束，生成黑底酷炫 3D 螺旋轨迹图，耗时 18 分, 300 卡, VAM 1350。一键分享到朋友圈，“征服圣彼得”。

### 2. Sarah - 写字楼碎片健身 (Primary User - Edge Case)

**Story**: 32岁金融分析师，利用午休在公司消防通道透气。
**The Journey**:

1.  **开场**: 午饭后进入楼梯间，只想轻量活动。
2.  **下楼插曲**: 爬到 15 楼接到电话需回 10 楼拿文件。Vertical 算法识别到下行气压变化与加速度特征，自动暂停“攀升累计”，语音提示“下行暂停记录”。
3.  **恢复**: 拿完文件重新上楼，记录自动恢复。
4.  **结局**: 完成 30 层攀爬，数据干净准确，无下楼噪音数据。

### 3. 系统管理员 - 运营后台 (Admin User)

**Story**: 负责维护地标数据和反作弊。
**The Journey**:

1.  **场景**: 收到反馈某地标解锁过早。Admin 登录后台校准该地标“触发高度”。
2.  **监控**: 发现某用户 VAM 5000+ (超人类极限)，系统标记为“疑似作弊/电梯”。Admin 一键封禁其排行榜资格。

### Journey Requirements Summary

- **传感与算法**: VAM 实时计算、下行/电梯剔除算法、自动暂停/恢复。
- **交互与反馈**: 锁屏/后台运行、TTS 语音播报、3D 路径实时渲染、视觉化目标引导。
- **社交与增长**: 3D 螺旋轨迹生成 (Collection & Constellation)、图片/视频分享。
- **后台管理**: 地标数据配置系统、反作弊 (Anti-Cheat) 逻辑、用户数据异常监控。

## Domain-Specific Requirements

### Compliance & Regulatory

- **Safety Disclaimer**: 必须在首次启动及“开始运动”前展示显眼的健康风险免责声明（爬楼属于高强度心肺运动），建议用户量力而行。

### Technical Constraints (Privacy & Safety)

- **Privacy - Node Hiding**: 在生成分享卡片/查看 3D 轨迹时，提供“隐藏节点”功能 (Hide Nodes)，允许用户手动剔除/隐藏特定的地理位置节点（如家庭或办公地址），保护隐私。
- **Data Ownership**: 生成的运动健康数据归用户所有。MVP 阶段暂不强制要求数据导出功能，但需确保数据存储安全。

### Risk Mitigations

- **Over-exertion Risk**: 通过 UI 提示或文案引导，建议用户关注自身感受，避免过度训练。

## Innovation & Novel Patterns

### Detected Innovation Areas

- **Gamification of Struggle (Urban Exploration)**: 将枯燥的爬楼重构为“垂直资产收集”游戏。用户扮演“城市探险家”，通过物理攀登解锁并收集地标建筑，而非单纯记录数据。
- **Visual Storytelling (The Constellation)**: 摒弃传统的 2D 折线图，首创 **3D 螺旋轨迹 (DNA Spiral)** 与 **星群连接 (Constellation)** 可视化。将用户的运动足迹转化为独一无二的 3D 艺术模型。
- **Social Currency (Insta-Ready)**: 专注于生成具有高审美价值、科幻感极强的 3D 轨迹图 (Static/Video)，使其成为自带流量的社交货币，打破运动 App 分享同质化的僵局。

### Market Context & Competitive Landscape

- **现状**: 现有爬楼/高度计 App（如 iOS 自带健康、第三方高度计）多为纯工具属性，UI 简陋，缺乏激励机制和美学设计。
- **差异化**: Vertical 切入“数据美学”与“游戏化”空白点，利用垂直这一冷门维度，打造差异化的运动体验。

### Validation Approach

- **Share Rate Metric**: 核心验证指标为“分享率”——即用户完成运动后，主动生成并保存/分享 3D 轨迹图的比例。
- **Viral Loop**: 监测社交媒体（朋友圈/Ins/小红书）上各渠道的新增用户来源，验证“3D 螺旋图”的吸量能力。

### Risk Mitigation

- **Novelty Wear-off**: 针对游戏化新鲜感消退的风险，通过后续迭代开放“自由连接 (Free-form Connection)”和“全区排行榜”来维持长期趣味性。

## Mobile App Specific Requirements

### Platform Strategy

- **Architecture**: 采用 **Native (iOS/Android)** 开发核心传感器模块与 3D 渲染模块，以确保极致性能与低功耗控制。非核心 UI 可考虑 Hybrid 方案。
- **3D Engine**: 使用原生图形库 (Metal / Vulkan) 或高性能 3D 引擎 (如 SceneKit / Unity as Library) 实现 60fps 流畅渲染，拒绝 WebGL 在移动端的性能妥协。

### Offline Capabilities

- **Sync Strategy**: 采用 **Local-First** 架构。所有运动数据（气压、加速度、GPS点序列）优先写入本地数据库 (Realm/SQLite)。
- **Network Handling**: 支持在消防通道等无信号环境下的完整记录。网络恢复后，后台自动静默同步数据至云端，确保数据零丢失。

### Device Permissions & Background Mode

- **Adaptive Tracking**: 提供用户可配置的追踪模式：
  - **High Fidelity (高精度模式)**: 申请后台 GPS 持续定位权限，生成完整的 3D 螺旋轨迹（耗电较高，适合户外/半户外）。
  - **Eco Mode (省电/室内模式)**: 锁屏后仅依赖气压计与计步器记录高度/层数，暂停 GPS 采样（不生成 3D 轨迹，仅记录垂直数据）。
- **Compliance Strategy**: 在 App Store 审核时，强调产品的“户外锻炼 (Outdoor Workout)”与“轨迹记录”属性，以通过后台定位权限审核。

### Store Requirements

- **Category**: Health & Fitness / Navigation
- **Privacy Manifest**: 需明确声明收集气压与位置数据用于运动分析与视觉化生成，而非广告追踪。

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** **Experience MVP (体验验证型)**。主打“数据美学”和“游戏化”，必须在视觉体验和交互手感上达到“Wow”的级别，验证“3D 可视化 + 垂直收集”能否驱动用户分享与留存。
**Resource Requirements:** Mobile Native Dev (iOS/Android) x2, 3D Tech Artist x1, Backend x1.

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**

- Liam (高效减脂) - 完整记录与分享。
- Sarah (碎片健身) - 离线记录与自动暂停。
- Admin - 基础地标配置（配置文件或简单后台）。

**Must-Have Capabilities:**

1.  **Tracking Core**: 高精度气压计算法 (Local-First, Offline-Ready)。
2.  **Visualization**: Native 3D 渲染 (Spiral & Constellation), 内置 5-10 个高精度地标。
3.  **Social Sharing**: 一键生成高质量 3D 轨迹图/视频，支持隐藏隐私节点。
4.  **System**: 免责声明，隐私合规，基础账号系统 (Guest/Apple ID)。

### Post-MVP Features

**Phase 2 (Growth & Retention):**

- **Leaderboards**: 好友排名、全区 VAM 排名。
- **Custom Geometry**: 自定义轨迹形状生成。
- **Wearable**: 独立 Apple Watch App。
- **Mix Mode**: 户外爬山模式。

**Phase 3 (Expansion):**

- **AR Real-time**: 实地 AR 轨迹悬浮体验。
- **Guild/Team**: 组队攻克超大地标。
- **Platform**: 开放地标创作社区。

### Risk Mitigation Strategy

**Technical Risks (Performance)**: 3D 渲染在旧机型上的发热与掉帧。

- _Mitigation_: MVP 优先适配近 3 年主流机型 (iPhone 12+, Android Flagships)，旧机型提供降级 2D/简易 3D 视图。

**Content Risks (Retention)**: 内置地标过少导致用户流失。

- _Mitigation_: 引入“虚拟无限塔”模式用于单纯刷记录，鼓励重复挑战已解锁地标以刷新 Personal Best (Speedrun)。

## Functional Requirements

### 1. Tracking Core (运动与传感)

- **FR-TC-01**: 用户可以开始一次“垂直攀升”记录，App 必须实时采集气压、加速度传感器数据。
- **FR-TC-02**: 系统必须能实时计算 VAM (垂直升速)，分辨率为米/小时。
- **FR-TC-03**: 系统必须能识别“下行”或“电梯”状态，并自动暂停累计高度和 VAM。
- **FR-TC-04**: 用户可以在无网络环境下完整记录一次运动数据 (Local-First)。
- **FR-TC-05**: 系统必须在后台（锁屏或切到其他 App）持续记录运动数据。
- **FR-TC-06**: 系统必须在网络恢复时，自动将本地数据同步至云端。

### 2. Visual Storytelling (可视化与交互)

- **FR-VS-01**: 用户可以在运动过程中看到基于当前层数映射的“虚拟高度”（如：已到达圣彼得大教堂顶端）。
- **FR-VS-02**: 用户可以查看本次运动生成的 3D 螺旋轨迹 (DNA Spiral)，支持旋转、缩放。
- **FR-VS-03**: 用户可以查看基于历史记录生成的“星群地图” (Constellation Map)，所有解锁地标在视觉上相连。
- **FR-VS-04**: 用户可以在“高精度模式”和“省电模式”之间切换，前者记录 GPS 轨迹，后者仅记录高度。

### 3. Social & Sharing (社交分享)

- **FR-SS-01**: 用户可以一键生成本次运动的 3D 轨迹图片或短视频 (Share Card)。
- **FR-SS-02**: 用户在生成分享卡片时，可以选择“隐藏隐私节点”，系统需自动剔除起点/终点附近的轨迹点。
- **FR-SS-03**: 分享卡片必须包含核心数据（高度、耗时、热量、VAM）和 3D 模型渲染图。

### 4. Landmark & Assets (地标系统)

- **FR-LA-01**: 系统需内置首批精选地标（MVP 范围: 5-10个），包含其高度数据和 3D 简模。
- **FR-LA-02**: 用户攀爬高度达到地标高度时，视为“点亮/收集”该地标。
- **FR-LA-03**: 管理员 (Admin) 可以通过配置文件或简易后台更新地标数据。

### 6. Internationalization (国际化)

- **FR-IN-01**: 用户可以在设置中切换应用语言，首期支持 **简体中文** 与 **英文**。
- **FR-IN-02**: 系统所有 UI 文案、地标名称、成就描述及分享卡片模板需支持多语言本地化。
- **FR-IN-03**: TTS 语音播报（高度、速度、地标解锁）需根据选择的语言自动切换发音引擎。
- **FR-IN-04**: 系统必须支持“跟随系统语言”的自动识别逻辑。

### 7. System & Account (系统基础)

- **FR-SY-01**: 用户可以在未登录状态下使用 Guest 模式体验所有核心功能（数据存本地）。
- **FR-SY-02**: 用户可以通过 Apple ID 登录/绑定账号，实现跨设备数据云同步。
- **FR-SY-03**: 系统必须在首次使用前展示《健康风险免责声明》并强制用户同意。
- **FR-SY-04**: 用户可以校准当前楼层的标准高度（默认 3米/层）。

## Non-Functional Requirements

### Performance

- **Frame Rate (FPS)**: 在 High Quality 模式下，3D 直播与轨迹回放界面必须保持 **稳定 60fps** (近 3 年 iPhone/Android 旗舰)。Lower-end 设备降级模式下不低于 30fps。
- **Launch Time**: 冷启动到“开始运动”按钮可点击，需在 **1.5秒** 内完成。
- **Sensor Latency**: 气压与高度数据的 UI 刷新延迟 < 200ms。

### Battery Efficiency

- **Consumption**: 在后台高精度记录模式下，每小时耗电量不得高于 8-10%。
- **Thermal**: 3D 渲染持续运行 15 分钟，设备表面温度上升不得超过 5°C。

### Reliability & Accuracy

- **Data Integrity**: 在电量耗尽自动关机前，必须自动保存当前未完结的运动记录。
- **Accuracy**: 楼层判断准确率需 > 95% (即爬 20 层，误差不超过 ±1 层)。

### Storage

- **Footprint**: App 安装包体积控制在 **150MB** 以内（不含在线下载的地标资产）。
- **Offline Data**: 离线数据库需支持存储至少 3 年的运动数据，占用空间 < 500MB。

### Security

- **Privacy**: 导出的分享卡片/视频中，不得包含任何原始 GPS 元数据 (EXIF)。

### Internationalization

- **NFR-IN-01**: 语言切换必须在用户选择后立即生效，UI 刷新无明显闪烁，且无需后台重启应用。
- **NFR-IN-02**: 翻译文案需考虑不同语言的长度差异，UI 布局应具备自适应能力（如德语通常比英语长）。
