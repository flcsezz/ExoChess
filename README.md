# ♟️ ExoChess Mobile

<p align="center">
  <img src="https://raw.githubusercontent.com/flcsezz/ExoChess/main/assets/images/home_logo.png" width="200" alt="ExoChess Logo">  
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://m3.material.io"><img src="https://img.shields.io/badge/Material--Design-3-%23757575.svg?style=for-the-badge&logo=material-design&logoColor=white" alt="Material Design 3"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License"></a>
</p>

**ExoChess** is a high-performance, professional chess application built with Flutter. It focuses on providing a world-class experience for local play, advanced analysis, and tactical training, powered by the latest Stockfish engines and a modern Material 3 interface.

---

## 🚀 Key Features

### 🧠 Advanced Analysis

- **Stockfish 16+ Integration**: Local engine analysis with move-quality labels and piece badges.
- **Opening Explorer**: Master the opening phase with deep database integration.
- **Analysis Board Intelligence**: Real-time evaluation gauge and best-move suggestions.

### 🧩 Puzzles & Training

- **Daily Puzzles**: Curated tactical challenges updated every 24 hours.
- **Puzzle Streak & Storm**: Test your speed and consistency in high-pressure modes.
- **Coordinate Training**: Improve your board vision and notation speed.

### 🎮 Gameplay

- **Over-the-Board (OTB)**: Professional chess clock and multi-variant support for local play.
- **Correspondence**: Play long-term games at your own pace.
- **External Fetch**: Seamlessly import and review your games from Lichess and Chess.com.

---

## 📱 Visuals (Material 3)

The app features a clean, professional interface following the latest **Material 3** guidelines, including dynamic color support and a professional card-based layout.

<p align="center">
  <img src="https://raw.githubusercontent.com/flcsezz/ExoChess/main/assets/videos/m3.gif" width="600" alt="ExoChess Material 3 Demo">
</p>

---

## 📥 Getting Started

### Download the App

You can download the latest optimized APKs directly from our GitHub Releases page. We use **ABI Splitting** to ensure you get the smallest possible file for your device.

👉 **[Download Latest Stable Release (v0.22.7)](https://github.com/flcsezz/ExoChess/releases/latest)**

| Architecture                                                                                        | Device Type                             | Size    |
| --------------------------------------------------------------------------------------------------- | --------------------------------------- | ------- |
| **[arm64-v8a](https://github.com/flcsezz/ExoChess/releases/download/v0.22.7/exochess-arm64.apk)**   | Modern 64-bit devices (**Recommended**) | ~113 MB |
| **[armeabi-v7a](https://github.com/flcsezz/ExoChess/releases/download/v0.22.7/exochess-armv7.apk)** | Older 32-bit devices                    | ~111 MB |
| **[x86_64](https://github.com/flcsezz/ExoChess/releases/download/v0.22.7/exochess-x86_64.apk)**     | Emulators & Intel Tablets               | ~115 MB |

### 🛠️ Development Setup

1. **Prerequisites**: Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. **Clone**: `git clone https://github.com/flcsezz/ExoChess.git`
3. **Init**:
   ```bash
   flutter pub get
   dart run build_runner build
   ```
4. **Run**: `flutter run --release`

---

## 🏗️ Architecture & Tech Stack

- **Framework**: Flutter 3.x (Dart 3.x)
- **State Management**: Riverpod (Notifier & FutureProvider)
- **Design System**: Material Design 3 with custom high-contrast components.
- **Engines**: `multistockfish` (bundling Stockfish 16, variants, and chess binaries).
- **Optimization**: Per-ABI splitting for minimal installation footprint.

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

_ExoChess is a free and open-source hobby project. Designed for players, by players._
