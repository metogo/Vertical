---
stepsCompleted: ["validate-prerequisites"]
inputDocuments:
  [
    "/Users/fanhua/plan/vertical/_bmad-output/planning-artifacts/prd.md",
    "/Users/fanhua/plan/vertical/_bmad-output/planning-artifacts/architecture.md",
    "/Users/fanhua/plan/vertical/_bmad-output/planning-artifacts/ux-design-specification.md",
  ]
---

# vertical - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for vertical, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

- **FR-TC-01**: 用户可以开始一次“垂直攀升”记录，App 必须实时采集气压、加速度传感器数据。
- **FR-TC-02**: 系统必须能实时计算 VAM (垂直升速)，分辨率为米/小时。
- **FR-TC-03**: 系统必须能识别“下行”或“电梯”状态，并自动暂停累计高度和 VAM。
- **FR-TC-04**: 用户可以在无网络环境下完整记录一次运动数据 (Local-First)。
- **FR-TC-05**: 系统必须在后台（锁屏或切到其他 App）持续记录运动数据。
- **FR-TC-06**: 系统必须在网络恢复时，自动将本地数据同步至云端。
- **FR-VS-01**: 用户可以在运动过程中看到基于当前层数映射的“虚拟高度”（如：已到达圣彼得大教堂顶端）。
- **FR-VS-02**: 用户可以查看本次运动生成的 3D 螺旋轨迹 (DNA Spiral)，支持旋转、缩放。
- **FR-VS-03**: 用户可以查看基于历史记录生成的“星群地图” (Constellation Map)，所有解锁地标在视觉上相连。
- **FR-VS-04**: 用户可以在“高精度模式”和“省电模式”之间切换，前者记录 GPS 轨迹，后者仅记录高度。
- **FR-SS-01**: 用户可以一键生成本次运动的 3D 轨迹图片或短视频 (Share Card)。
- **FR-SS-02**: 用户在生成分享卡片时，可以选择“隐藏隐私节点”，系统需自动剔除起点/终点附近的轨迹点。
- **FR-SS-03**: 分享卡片必须包含核心数据（高度、耗时、热量、VAM）和 3D 模型渲染图。
- **FR-LA-01**: 系统需内置首批精选地标（MVP 范围: 5-10个），包含其高度数据和 3D 简模。
- **FR-LA-02**: 用户攀爬高度达到地标高度时，视为“点亮/收集”该地标。
- **FR-LA-03**: 管理员 (Admin) 可以通过配置文件或简易后台更新地标数据。
- **FR-SY-01**: 用户可以在未登录状态下使用 Guest 模式体验所有核心功能（数据存本地）。
- **FR-SY-02**: 用户可以通过 Apple ID 登录/绑定账号，实现跨设备数据云同步。
- **FR-SY-03**: 系统必须在首次使用前展示《健康风险免责声明》并强制用户同意。
- **FR-SY-04**: 用户可以校准当前楼层的标准高度（默认 3米/层）。

### NonFunctional Requirements

- **Performance**: Frame Rate > 60fps (High Quality Mode), 30fps (Low Power). Launch Time < 1.5s.
- **Battery**: < 8-10% per hour in high fidelity mode.
- **Reliability**: Floor detection accuracy > 95%. Auto-save on low battery.
- **Storage**: App size < 150MB. Local DB < 500MB (3 years data).
- **Privacy**: No GPS EXIF in shared images. Hide Nodes feature.

### Additional Requirements

- **Architecture (Starter)**: Custom iOS Scaffold (SwiftUI + Metal + CoreMotion + BackgroundTasks).
- **Architecture (Data)**: GRDB (SQLite) for high-frequency sensor logs.
- **Architecture (Pattern)**: The Composable Architecture (TCA) for state management.
- **Architecture (Privacy)**: Location data truncation (Altitude only) strategy.
- **UX (Visuals)**: Cyberpunk Minimalist aesthetic, Neon colors on Black.
- **UX (Haptics)**: "Altimeter Heartbeat" haptic coding pattern.
- **UX (Interaction)**: "Pocket Mode" for blind operation via haptics.
- **UX (Metaphor)**: Vertical Axis Timeline as primary navigation.

### FR Coverage Map

### FR Coverage Map

FR-TC-01: Epic 1 - Core sensor data collection
FR-TC-02: Epic 1 - Real-time VAM calculation
FR-TC-03: Epic 1 - Auto-pause logic for elevators/descent
FR-TC-04: Epic 1 - Offline-first architecture
FR-TC-05: Epic 1 - Background task persistence
FR-TC-06: Epic 6 - Cloud synchronization
FR-VS-01: Epic 4 - Virtual height mapping to landmarks
FR-VS-02: Epic 3 - 3D spiral trajectory visualization
FR-VS-03: Epic 3 - Constellation map view
FR-VS-04: Epic 1 - Tracking modes (High/Eco)
FR-SS-01: Epic 5 - Social share card generation
FR-SS-02: Epic 5 - Privacy node hiding
FR-SS-03: Epic 5 - Share card data rendering
FR-LA-01: Epic 4 - Landmark asset management
FR-LA-02: Epic 4 - Landmark unlocking logic
FR-LA-03: Epic 4 - Landmark configuration
FR-SY-01: Epic 6 - Guest mode support
FR-SY-02: Epic 6 - Apple ID login
FR-SY-03: Epic 1/6 - Disclaimer and compliance
FR-SY-04: Epic 2 - Floor height calibration settings

## Epic List

### Epic 1: The Sensor Foundation

**Goal**: Establish a robust, always-on reliable sensor fusion system that acts as the "heartbeat" of the app.
**Value**: Users get accurate, battery-efficient climb data that never gets lost, even when the phone is locked.
**FRs covered**: FR-TC-01, FR-TC-02, FR-TC-03, FR-TC-04, FR-TC-05, FR-VS-04, FR-SY-03

### Epic 2: The Vertical Timeline (UX Core)

**Goal**: Create the primary "Vertical Axis" interface and "Pocket Mode" interactions.
**Value**: Users experience a seamless, "blind-operation-friendly" workout flow that feels like a natural extension of climbing.
**FRs covered**: FR-SY-04, UX-Interaction Patterns (Pocket Mode, Vertical Navigation)

### Epic 3: 3D Visualization System

**Goal**: Implement the Metal-based rendering engine for the DNA Spirals and Particle systems.
**Value**: Users are rewarded with stunning, cinema-grade 3D visuals that represent their effort.
**FRs covered**: FR-VS-02, FR-VS-03

### Epic 4: Gamification & Landmarks

**Goal**: Implement the "Urban Explorer" game mechanics with real-world landmark data.
**Value**: Users feel a sense of progression and conquest by virtually climbing famous buildings.
**FRs covered**: FR-VS-01, FR-LA-01, FR-LA-02, FR-LA-03

### Epic 5: Social Sharing & Privacy

**Goal**: Build the "Social Currency" engine with privacy-first design.
**Value**: Users can safely share their achievements, driving organic growth for the app.
**FRs covered**: FR-SS-01, FR-SS-02, FR-SS-03

### Epic 6: User System & Cloud

**Goal**: Ensure data persistence and cross-device synchronization.
**Value**: Users own their data forever and can switch devices seamlessy.
**FRs covered**: FR-TC-06, FR-SY-01, FR-SY-02

## Epic 1: The Sensor Foundation

**Goal**: Establish a robust, always-on reliable sensor fusion system that acts as the "heartbeat" of the app.

### Story 1.1: Project Scaffold & Dependency Injection

As a Developer, I want to set up the Xcode Service and Dependency Injection, So that feature development is decoupled from hardware.
**Acceptance Criteria:**
**Given** A new Xcode project configured with TCA
**When** I access `DependencyValues.sensorClient`
**Then** It returns a mock value in previews and live value in simulater/device
**And** The app compiles without Strict Concurrency warnings

### Story 1.2: Core Motion Barometer Integration

As a User, I want the app to read my altitude changes, So that I can track my climb.
**Acceptance Criteria:**
**Given** `SensorClient.liveValue` is active
**When** The device changes altitude
**Then** The `altitudeStream` yields new `Measurement<UnitLength>` values
**And** Errors (e.g., no sensor) are gracefully handled

### Story 1.3: Tracker Logic & VAM Calculation

As a User, I want to see my Vertical Ascent Speed (VAM), So that I can gauge my intensity.
**Acceptance Criteria:**
**Given** A stream of altitude updates
**When** 10 seconds pass
**Then** The VAM is recalculated based on the rolling average
**And** The `TrackerFeature.State` updates with the new VAM

### Story 1.4: Background Task & Location Manager

As a User, I want tracking to continue when I lock my phone, So that I don't drain battery with the screen on.
**Acceptance Criteria:**
**Given** A recording session is active
**When** I lock the screen for 5 minutes
**Then** The debug logs show continuous sensor readings
**And** The Location Manager is active with `kCLLocationAccuracyReduced`

### Story 1.5: GRDB Data Persistence

As a User, I want my data saved automatically, So that I don't lose it if the app crashes.
**Acceptance Criteria:**
**Given** Sensor data is arriving
**When** A new reading arrives
**Then** It is inserted into the `SensorReadings` SQLite table
**And** The write happens on a background actor

### Story 1.6: Auto-Pause Logic

As a User, I want the app to ignore elevator rides, So that my stats are legit.
**Acceptance Criteria:**
**Given** I am recording
**When** I step into an elevator (rapid pressure change + low acceleration noise)
**Then** The recording state switches to `.paused`
**And** A system notification triggers "High speed detected, pausing"

## Epic 2: The Vertical Timeline (UX Core)

**Goal**: Create the primary "Vertical Axis" interface and "Pocket Mode" interactions.

### Story 2.1: Vertical Axis Navigation

As a User, I want to scroll a vertical ruler, So that I can feel the scale of the height.
**Acceptance Criteria:**
**Given** The Home Screen
**When** I scroll vertically
**Then** The ruler moves with inertial scrolling
**And** Landmarks appear at correct relative positions

### Story 2.2: Live HUD Overlay

As a User, I want to see big neon numbers, So that I can read stats while running.
**Acceptance Criteria:**
**Given** I am in a workout
**When** My VAM changes
**Then** The HUD number updates with a "slot machine" animation
**And** The color shifts from Blue (Idle) to Pink (Peak)

### Story 2.3: Pocket Mode Haptics

As a User, I want to feel my progress, So that I don't have to look at the screen.
**Acceptance Criteria:**
**Given** Pocket Mode is active
**When** I climb 1 floor (3 meters)
**Then** A heavy haptic impact plays
**And** When I reach a landmark, a double pulse plays

## Epic 3: 3D Visualization System

**Goal**: Implement the Metal-based rendering engine.

### Story 3.1: Metal Shader Particle System

As a User, I want to see flowing particles, So that I feel the speed visually.
**Acceptance Criteria:**
**Given** Valid VAM data
**When** VAM increases
**Then** The particle speed in the Metal View increases
**And** FPS remains > 60 on iPhone 13+

### Story 3.2: 3D Spiral Generation

As a User, I want to see my path as a 3D wireframe, So that it looks cool.
**Acceptance Criteria:**
**Given** A set of completed mock sensor points
**When** I open the Result View
**Then** A 3D spiral mesh is generated matching the data points
**And** I can rotate it with touch gestures

## Epic 4: Gamification & Landmarks

**Goal**: Implement the "Urban Explorer" game mechanics.

### Story 4.1: Landmark Data Management

As a Product Owner, I want to configure landmarks, So that user have goals.
**Acceptance Criteria:**
**Given** A JSON configuration file
**When** The app launches
**Then** `LandmarkClient` loads the definitions (Name, Height, 3D Model Name)

### Story 4.2: Progress & Unlocking Logic

As a User, I want to unlock buildings, So that I feel achievement.
**Acceptance Criteria:**
**Given** I have climbed 300 meters
**When** I pass the height of the Eiffel Tower (300m)
**Then** The UI shows "Unlocked"
**And** Calculate progress percentage to the next landmark

## Epic 5: Social Sharing & Privacy

**Goal**: Build the "Social Currency" engine with privacy-first design.

### Story 5.1: Privacy Node Hiding

As a User, I want to hide my home location, So that I'm safe.
**Acceptance Criteria:**
**Given** A 3D path with GPS data
**When** I toggle "Hide Start/End"
**Then** The first and last 200m of the 3D spiral are clipped/hidden
**And** The altitude data remains visible

### Story 5.2: Cinematic Card Generation

As a User, I want a cool image to share, So that I can post to Instagram.
**Acceptance Criteria:**
**Given** A workout result
**When** I tap Share
**Then** A high-res image is rendered continuously off-screen
**And** The `UIActivityViewController` appears with the image

## Epic 6: User System & Cloud

**Goal**: Ensure data persistence and synchronization.

### Story 6.1: Onboarding & Disclaimer

As a Lawyer, I want users to agree to risks, So that we don't get sued.
**Acceptance Criteria:**
**Given** First app launch
**When** The app opens
**Then** A full-screen disclaimer appears
**And** "Agree" enables the "Start" button

### Story 6.2: CloudKit Sync

As a User, I want my data on my iPad, So that I can view it on a big screen.
**Acceptance Criteria:**
**Given** I am logged into iCloud
**When** I save a record on iPhone
**Then** It appears in CloudKit Dashboard
**And** It syncs to other devices
