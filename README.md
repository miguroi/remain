# Remain

A macOS horror typing game. You open a locker you weren't supposed to, and something on the other side makes you type its words. Keep typing until the session ends — or it ends you.

## The Game

- Pick a locker. Most are wrong. One was always yours.
- Type the passage exactly as it appears against a 60-second timer.
- Mistakes trigger reactions — screen shakes, smeared words, ink fades, falling letters.
- Your speed (WPM) and accuracy are tracked and thrown back at you when the session ends.

The experience leans on sound and visual effects, so play with audio on.

## Tech Stack

- SwiftUI (macOS app)
- Combine for game state
- AVFoundation for audio and camera
- Custom registered fonts (FingerPaint, Boyrun)

## Running

1. Open the project in Xcode:
   ```sh
   open Remain.xcodeproj
   ```
2. Select the **Remain** scheme and run (⌘R) on My Mac.

The app requests camera access — granting it is part of the experience.

## Project Structure

```
Remain/
├── RemainApp.swift        App entry; registers fonts, sets window
├── Views/
│   ├── ContentView.swift  Locker selection
│   ├── TypingView.swift   Typing session & visual effects
│   └── ResultView.swift   End-of-session results
├── Models/
│   └── GameState.swift    Session state, timer, WPM/accuracy, texts
├── Helpers/
│   ├── CameraManager.swift
│   ├── FlowLayout.swift
│   └── KeyPressHandler.swift
├── Fonts/                 Custom .ttf fonts
└── Assets.xcassets        Images & app assets
```
