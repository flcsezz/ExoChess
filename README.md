# ♟️ ExoChess Mobile

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Material Design 3](https://img.shields.io/badge/Material--Design-3-%23757575.svg?style=for-the-badge&logo=material-design&logoColor=white)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](./LICENSE)

**ExoChess** is a high-performance, professional chess application built with Flutter. It focuses on providing a world-class experience for local play, advanced analysis, and tactical training, powered by the latest Stockfish engines.

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

## 📱 Getting Started

### 📥 Download the App
You can download the latest optimized APKs directly from our GitHub Releases page:

- **[Latest Stable Release (APKs)](https://github.com/flcsezz/Chessigma/releases/latest)**
  - `exochess-arm64.apk`: Optimized for modern 64-bit devices (Recommended).
  - `exochess-armv7.apk`: Support for older 32-bit devices.
  - `exochess-x86_64.apk`: For emulators and specific Intel-based tablets.

### 🛠️ Development Setup
1. **Prerequisites**: Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. **Clone**: `git clone https://github.com/flcsezz/Chessigma.git`
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
*ExoChess is a free and open-source hobby project. Designed for players, by players.*
