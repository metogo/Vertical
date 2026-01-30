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
lastEdited: "2026-01-22"
editHistory:
  - date: "2026-01-27"
    changes: "Integrated HealthKit retro-sync (7-day window), dynamic count animation, and multi-dimensional stats/trends views."
  - date: "2026-01-22"
    changes: "Added FR-TC-06 (Retroactive Detection) and FR-TC-07 (Passive Sync) to solve friction in fragmented sessions."
  - date: "2026-01-22"
    changes: "Added FR-VS-06 (AMPK Science Board) for metabolic education and concept introduction."
  - date: "2026-01-22"
    changes: "Integrated 'AMPK MetaVision 3D' core features, Karvonen heart rate engine, and real-time metabolic visualization requirements."
  - date: "2026-01-19"
    changes: "Added internationalization (i18n) requirements for Chinese and English support."
---

# Product Requirements Document - Vertical

**Author:** Fanhua
**Date:** 2026-01-17

## Executive Summary

Vertical 是一款专注于垂直攀升的健康管理与运动 App。不同于传统的竞技型运动工具，它利用其独特的 **“AMPK MetaVision 3D”** 引擎，将不可见的分子代谢过程（燃脂、血糖调节、线粒体再生及细胞自噬）进行实地 3D 可视化。

基于斯坦福神经科学教授 Dr. Huberman 等倡导的持续肌肉收缩（AMPK 激活）理念，Vertical 将久坐办公环境下的每一次攀爬微运动转化为高效的代谢干预。用户不仅在纪录高度，更是在实时观察自己身体内部的“数字化孪生”如何进行能量转换与细胞清理，为现代职场人提供极致的生理反馈与科学掌控感。

## Project Classification

- **Project Type:** Mobile App
- **Domain:** Sport / Fitness / Health / Longevity
- **Complexity:** Medium
- **Context:** Greenfield (Pivoted to Wellness/Metabolic Health)

## Success Criteria

### User Success

- **代谢激活 (Metabolic Activation)**: 用户通过“少量多次”的攀爬有效地激活 AMPK 路径。
- **线粒体与自噬达标 (Cellular Health)**: 用户通过追踪“线粒体生成指数”和“自噬触发深度”，量化细胞排毒与动力源扩容的实际进度。
- **成就感 (Sense of Achievement)**: 通过 3D 数字化孪生人体的视觉爆发（如 GLUT4 吸糖特效），感受到每一米运动对生理指标的即时改善。
- **减脂效率 (Efficiency)**: 基于 $HRR\%$ 计算的实时 RER 估算，让用户明确当前的脂肪氧化状态。

### Business Success

- **用户习惯 (Habit Formation)**: 目标用户（如写字楼白领）形成“见梯即爬”的碎片化运动习惯，每日启动频次平均 > 3 次。

### Technical Success

- **数据精准度 (Accuracy)**: 每一米高度变化的捕捉灵敏度。
- **UI 响应 (UI Hierarchy)**: 核心高度指标占据 60% 以上视觉重心，VAM 作为辅助动态。

### Measurable Outcomes

- **核心指标**: 每日活跃攀爬频次 (Micro-sessions per Day)。
- **留存感**: > 40% 的活跃用户每周至少访问一次“数据统计”页面复盘。
- **分享率**: > 20% 的用户分享“今日累计高度”达成图。

## Product Scope

### MVP - Minimum Viable Product

### MVP - Minimum Viable Product

- **核心记录**: 气压计高度融合算法，以“当前累计高度”为最优先展示指标，实时显示层数、VAM。
- **3D 实时代谢看板 (MetaVision)**: 屏幕中央显示 **3D 数字化孪生人体模型**。基于 $HRR\%$ 实时渲染：
  - **脂肪分解金流**: 心率 45%-60% 区间触发。
  - **GLUT4 吸糖特效**: 心率 60%-75% 区间触发。
- **分享**: 支持“实时代谢报告”与 3D 轨迹合成分享卡片。
- **核心地标**: 内置 5-10 个高度锚点。

### Growth Features (Post-MVP)

- **细胞清理监控**: 线粒体再生指数与自噬触发深度追踪。
- **空腹自噬模式**: 配合禁食计时器，优化自噬触发曲线。
- **社交排行**: 基于线粒体积攒指数的排行榜。

- **社交排行**: 好友间的垂直高度排行榜。
- **更多地标**: 扩展全球著名高层建筑地标包。
- **可穿戴支持**: 独立 Apple Watch 应用。
- **AR 体验**: 基于地理位置的实景 AR 打卡。

### Vision (Future)

- 打造全球最大的垂直运动数据库与社区，定义“垂直跑”运动标准。

## User Journeys

### 1. Sarah - 代谢微干预 (Primary User - Success Path)

**Story**: 32岁金融分析师，深度认同“微运动”对控制血糖和胰岛素水平的价值。
**The Journey**:

1.  **开场**: 在格子间坐了 45 分钟后，Sarah 收到健康提醒。她走向消防通道。
2.  **攀爬**: 打开 Vertical，高度读数下方跳动着一个半透明的 3D 人体模型。
3.  **高潮**: 当她爬升到 8 楼，心率进入 65% $HRR\%$。屏幕上的人体模型肌肉纹理开始发出青色微光（GLUT4 激活特效），提示她肌肉正在高效从血液中抽取葡萄糖。
4.  **反馈**: 持续爬升 2 分钟后，AMPK 激活徽章点亮。App 提示：“细胞代谢火炉已启动”。
5.  **结局**: 到达 10 楼，Sarah 看着自己刚才运动生成的“线粒体闪烁”动画，感到前所未有的满足。她分享了一张带有 3D 轨迹和代谢摘要的卡片到动态，配文：“写字楼里的细胞清理”。

### 2. Liam - 高效减脂者 (Secondary User)

**Story**: 28岁广告人，追求攀升速度与挑战。
**The Journey**:

1.  **攀爬**: Liam 关注 VAM (垂直升速) 以评估训练强度。
2.  **反馈**: 虽然 VAM 在 UI 上降为次要，但当他冲刺时，高度变化的滚动速度与震动反馈依然能让他感受到肾上腺素。

### 4. David - 异步补录者 (Secondary User)

**Story**: 忙碌的白领，经常在爬楼梯时忘记打开 App，或者在手机没信号的地下停车场攀爬。
**The Journey**:

1.  **场景**: David 爬完 15 层楼后回到位子上，才想起没开 Vertical。
2.  **触发**: 第二天早上打开 App，系统立即弹窗提示：“检测到昨日有 15 层高质量攀爬数据，是否同步？”
3.  **反馈**: 点击确认后，首页的“今日累计高度”开始像流体一样动态增长，数字从 0 快速翻滚至 45m，同时伴随轻微的触觉反馈。
4.  **结局**: David 在统计页面的“周提要”中看到了这笔数据的加入，感受到了运动足迹的完整性。

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
- **FR-TC-02**: **指标优先级 (Metric Priority)**: 主界面必须以“当前累计高度 (Current Altitude)”作为第一视觉重心。
- **FR-TC-03**: 系统必须实时计算 VAM (垂直升速)，作为衡量代谢强度的辅助指标。
- **FR-TC-04**: 系统必须能识别“下行”或“电梯”状态，并自动暂停累计高度和 VAM，防止代谢数据注流。
- **FR-TC-05**: **实时代谢映射引擎**: 系统需接入 HealthKit/Google Fit 实时心率，利用卡式公式（Karvonen Formula）计算储备心率百分比（$HRR\%$）：
  - $HR_{target} = ((MHR - RHR) \times HRR\%) + RHR$
  - 需自动计算 $MHR$（基于年龄）并允许手动调整 $RHR$。
- **FR-TC-06**: **追溯性运动检测 (Retroactive Detection)**: App 启动或进入前台时，需通过 `CMPedometer` 自动检索过去 7 天的离线数据。系统需通过算法过滤掉非垂直攀爬数据（如平地步行），仅保留高度变化显著的片段并引导用户补录。
- **FR-TC-07**: **健康数据同步 (HealthKit Passive Sync)**: 自动同步 HealthKit 中的“已爬楼层”数据，确保即使用户未手动启动 App，长期的代谢积分（线粒体指数等）依然保持连续。
- **FR-TC-08**: **HealthKit 数据去重**: 当本地传感器实时记录的数据与补录数据在时间轴上重叠时，系统需自动去重，确保代谢指标不被重复计算。

### 2. Visual Storytelling (可视化与交互)

- **FR-VS-01**: 用户可以在运动过程中看到高度跳动的实时动画，强调“每一步都在增量”。
- **FR-VS-02**: **AMPK 状态指示器**: 当垂直位移持续超过一定阈值（如 2 分钟时，且心率处于对应区间），UI 展示“代谢激活中”反馈。
- **FR-VS-05**: **3D 数字化孪生视觉渲染**:
  - **Fat Burning (45-60% HRR%)**: 在模型腹部与皮下渲染金色能量流。
  - **Glucose Uptake (60-75% HRR%)**: 肌肉纹理脉冲发光。
  - **Mito-Biogenesis (75-90% HRR%)**: 全身蓝色微粒（线粒体）高频闪烁。
  - **Autophagy Pulse (>75% for 30min)**: 模型中心产生向外的全息脉冲波。
- **FR-VS-06**: **AMPK 科学观察站 (Science Board)**: 在 AMPK 徽章旁提供交互式信息入口。展示碎片化健康知识，解释 AMPK 激活原理及其与 3D 可视化效果的映射关系。
- **FR-VS-03**: 用户可以查看 3D 螺旋轨迹，但在运动首页，高度数值应盖过轨迹展示。
- **FR-VS-04**: 用户可以在“高精度模式” and “省电模式”之间切换，前者记录 GPS 轨迹，后者仅记录高度。
- **FR-VS-07**: **数值流式增长动画**: 同步历史数据或完成大型地标时，指标数值必须在 1.5s - 2.5s 内动态翻滚显示增长过程，并伴随 haptic 反馈。

### 3. Data Visualization (代谢量化指标)

- **FR-DV-01**: **线粒体生成指数**: 累计在 75%-90% $HRR\%$ 区间的有效锻炼分钟数。
- **FR-DV-02**: **脂肪氧化效率 (RER 估算)**: 根据实时心率与呼吸频率估算当前的呼吸交换率。
- **FR-DV-03**: **自噬触发深度**: 根据心率强度与持续运动时间的积分进行非线性建模展示。
- **FR-DV-04**: **多维统计分析**: 提供日、周、月、6个月、年的时间轴切换，核心展示：
  - 各周期累计攀爬米数柱状图。
  - 代谢强度区间占比分布图。
- **FR-DV-05**: **数据提要模块**: 仿 Health App 的 Summary 设计，展示“过去 7 天日均高度对比”及“周度/月度建议”。

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
- **FR-SY-05**: **健康声明显示**: 必须在设置或首页显著位置展示“本应用非医疗诊断工具”的免责声明。

## Non-Functional Requirements

### Performance

- **Performance - 3D Rendering**: 在 3D MetaVision 模式下，必须保持 **稳定 60fps**。渲染性能需针对 Metal (iOS) 和 Vulkan (Android) 进行优化。
- **Sensor Latency**: 从传感器/健康数据更新到 3D 视觉变化的端到端延迟必须控制在 **150ms** 以内。

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
