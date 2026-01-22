# Vertical - Urban Explorer Tracking

> 🌍 **[中文版本](README_CN.md)**

Vertical is a high-performance, immersive stair-climbing tracker designed for urban explorers. Built with **SwiftUI**, **The Composable Architecture (TCA)**, and **Metal**, it transforms your skyscraper ascents and urban climbs into a visually stunning experience.

## 🚀 Key Features

- **Real-time VAM HUD**: Track your Meters per Hour (VAM) with high precision using the iPhone barometer.
- **Metal Visualization**: A dynamic 3D particle system and spiral trajectory renderer that visualizes your climb as you go.
- **Landmark Discovery**: Unlock famous high-altitude monuments like the Statue of Liberty or the Burj Khalifa as you reach their respective heights.
- **Privacy-First Sharing**: Generate cinematic sharing cards with automatic GPS/Altitude clipping to obscure your starting and ending points.
- **CloudKit Sync**: Your climbs are automatically synced across your iCloud devices.
- **Native Experience**: Integrated with Haptic Feedback, Background Location preservation, and Local Notifications.

## 🛠 Tech Stack

- **Architecture**: The Composable Architecture (TCA)
- **Database**: GRDB (SQLite)
- **Graphics**: Metal (Custom Shaders)
- **Sensors**: CoreMotion (Barometer), CoreLocation (Background preservation)
- **Cloud**: CloudKit
- **UI**: SwiftUI (Neon Dark Aesthetic)

## 📁 Project Structure

- `Vertical/Sources/Features`: Component-based features (Tracker, Timeline, Result, Onboarding).
- `Vertical/Sources/Rendering`: Metal shaders and rendering logic.
- `Vertical/Sources/Clients`: Dependency injected clients for Sensors, Database, and CloudKit.
- `Vertical/Sources/Database`: Data models and persistence layers.

## 🚦 Getting Started

1. Open `Vertical/Vertical.xcodeproj` in Xcode 15+.
2. Ensure you are using a physical iPhone for the best experience (Barometer sensor required).
3. Build and Run on your device.
4. Agree to the Safety Disclaimer to start your first climb.

## 🛡 Disclaimer

Stair climbing is a high-intensity activity. Please ensure you are in good health and aware of your surroundings at all times. Vertical is for tracking purposes only.

---

\__Created by Fanhua & Antigravity (2026)_
