---
stepsCompleted:
  [
    "validate-prerequisites",
    "design-epics",
    "create-stories",
    "final-validation",
  ]
status: complete
inputDocuments:
  [
    "/Users/fanhua/plan/vertical/_bmad-output/planning-artifacts/prd.md",
    "/Users/fanhua/plan/vertical/_bmad-output/planning-artifacts/architecture.md",
    "/Users/fanhua/plan/vertical/_bmad-output/planning-artifacts/ux-design-specification.md",
  ]
---

# vertical - User Stories & Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for vertical, decomposing the requirements from the PRD, UX Design, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

- **FR-TC-01**: 用户可以开始一次“垂直攀升”记录，App 必须实时采集气压、加速度传感器数据。
- **FR-TC-02**: **指标优先级 (Metric Priority)**: 主界面必须以“当前累计高度 (Current Altitude)”作为第一视觉重心。
- **FR-TC-03**: 系统必须实时计算 VAM (垂直升速)，作为衡量代谢强度的辅助指标。
- **FR-TC-04**: 系统必须能识别“下行”或“电梯”状态，并自动暂停累计高度和 VAM，防止代谢数据注水。
- **FR-TC-05**: **实时代谢映射引擎**: 系统需接入 HealthKit/Google Fit 实时心率，利用卡式公式（Karvonen Formula）计算储备心率百分比（$HRR\%$）。
- **FR-VS-01**: 用户可以在运动过程中看到高度跳动的实时动画，强调“每一步都在增量”。
- **FR-VS-02**: **AMPK 状态指示器**: 当垂直位移持续超过一定阈值（如 2 分钟内持续上升），UI 应展示“代谢激活中”的视觉反馈（如炫彩辉光）。
- **FR-VS-03**: 用户可以查看 3D 螺旋轨迹，但在运动首页，高度数值应盖过轨迹展示。
- **FR-VS-04**: 用户可以查看基于历史记录生成的“星群地图” (Constellation Map)，所有解锁地标在视觉上相连。
- **FR-VS-05**: **3D 数字化孪生视觉渲染**: 在模型上渲染脂肪分解金流、GLUT4 吸糖特效、线粒体闪烁及自噬脉冲波。
- **FR-DV-01**: **线粒体生成指数**: 累计在 75%-90% $HRR\%$ 区间的有效锻炼分钟数。
- **FR-DV-02**: **脂肪氧化效率 (RER 估算)**: 实时显示当前的呼吸交换率。
- **FR-DV-03**: **自噬触发深度**: 根据心率强度与持续运动时间的积分进行展示。
- **FR-VS-06**: **AMPK 科学观察站 (Science Board)**: 在 AMPK 徽章旁提供交互式信息入口，展示碎片化健康知识。
- **FR-SS-01**: 用户一键生成本次运动的 3D 轨迹图片或短视频 (Share Card)。
- **FR-SS-02**: 用户在生成分享卡片时，可以选择“隐藏隐私节点”，系统需自动剔除起点/终点附近的轨迹点。
- **FR-SS-03**: 分享卡片必须包含核心数据（高度、耗时、热量、VAM）和 3D 模型渲染图。
- **FR-LA-01**: 系统需内置首批精选地标（MVP 范围: 5-10个），包含其高度数据和 3D 简模。
- **FR-LA-02**: 用户攀爬高度达到地标高度时，视为“点亮/收集”该地标。
- **FR-LA-03**: 管理员 (Admin) 可以通过配置文件或简易后台更新地标数据。
- **FR-SY-01**: 用户可以在未登录状态下使用 Guest 模式体验所有核心功能（数据存本地）。
- **FR-SY-02**: 用户可以通过 Apple ID 登录/绑定账号，实现跨设备数据云同步。
- **FR-SY-03**: 系统必须在首次使用前展示《健康风险免责声明》并强制用户同意。
- **FR-SY-04**: 用户可以校准当前楼层的标准高度（默认 3米/层）。
- **FR-TC-06**: **追溯性运动检测 (Retroactive Detection)**: 通过 `CMPedometer` 检索离线爬楼记录。
- **FR-TC-07**: **健康数据同步 (HealthKit Passive Sync)**: 自动同步 HealthKit 中的已爬楼层数据。
- **FR-TC-08**: **HealthKit 数据去重**: 当本地传感器数据与补录数据重叠时，系统需自动去重。
- **FR-VS-07**: **数值流式增长动画**: 同步历史数据或完成大型地标时，指标数值在 1.5s - 2.5s 内动态翻滚显示增长过程。
- **FR-DV-04**: **多维统计分析**: 提供日、周、月、6个月、年的时间轴切换，展示累计攀爬米数柱状图。
- **FR-DV-05**: **数据提要模块**: 仿 Health App 的 Summary 设计，展示“过去 7 天日均高度对比”。
- **FR-SY-05**: **健康声明显示**: 在设置或首页显著位置展示“本应用非医疗诊断工具”的免责声明。

## Epic List

### Epic 1: The Sensor Foundation

**FRs**: FR-TC-01, FR-TC-03, FR-TC-04, FR-SY-03

### Epic 2: Altitude Centric HUD

**FRs**: FR-TC-02, FR-VS-01, FR-SY-04, FR-VS-07

### Epic 3: Visual Storytelling (Metal & 3D)

**FRs**: FR-VS-03, FR-VS-04

### Epic 4: Gamification & Landmarks

**FRs**: FR-LA-01, FR-LA-02, FR-LA-03

### Epic 5: Social Sharing & Privacy

**FRs**: FR-SS-01, FR-SS-02, FR-SS-03

### Epic 6: User System & Cloud

**FRs**: FR-SY-01, FR-SY-02, FR-SY-05

### Epic 7: Metabolic Activation (AMPK Core)

**FRs**: FR-TC-05, FR-VS-02

### Epic 8: 3D MetaVision Dashboard

**FRs**: FR-VS-05, FR-VS-06, FR-DV-01, FR-DV-02, FR-DV-03

### Epic 9: Zero-Op Passive Tracking

**FRs**: FR-TC-06, FR-TC-07, FR-TC-08

### Epic 10: Retrospective & Insights

**FRs**: FR-DV-04, FR-DV-05

---

## Detailed Stories (Selection)

### Story 9.3: Overlapping Data Deduplication

**As a** Database Architect, **I want to** prevent double-counting of climbs, **So that** metabolic scores remain accurate even if passive and active tracking occur simultaneously.
**Acceptance Criteria:**

- Given a new set of HealthKit "Flights Climbed" samples
- When I process them for the database
- Then I check for existing `SensorReadings` or `Journeys` in the same time intervals
- And I discard or merge overlapping segments to ensure zero data duplication.

### Story 9.4: Numerical Stream Growth Animation

**As a** Designer, **I want** the backfilled meters to "roll up" visually, **So that** the user feels a sense of delayed reward.
**Acceptance Criteria:**

- Given a backfill session is confirmed
- When the dashboard values update
- Then the altitude number rolls from 0 to the target value over 1.5s - 2.5s
- And haptic "ticks" accompany the rolling numbers.

### Story 10.1: Multi-Dimensional Scaling Dashboard

**As a** User, **I want** to see my climb trends over different timeframes, **So that** I can track my long-term metabolic health.
**Acceptance Criteria:**

- Given the "Statistics" tab
- When I switch between Day, Week, Month, 6M, and Year
- Then the bar chart updates to show cumulative meters climbed for each sub-period.

### Story 6.3: Health Disclaimer Display

**As a** Legal Counsel, **I want** a permanent disclaimer in the app, **So that** users are always reminded this is not a medical device.
**Acceptance Criteria:**

- Given the Settings view or the start of the Home view
- Then a prominent "Non-medical diagnostic tool" disclaimer is visible.
