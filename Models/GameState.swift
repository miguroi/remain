//
//  GameState.swift
//  Remain
//
//  Created by Sayyidah Fatimah Azzahra on 25/03/26.
//

import SwiftUI
import Combine

class GameState: ObservableObject {
    @Published var currentText: String = ""
    @Published var typedText: String = ""
    @Published var mistakeCount: Int = 0
    @Published var isShaking: Bool = false
    @Published var sessionEnded: Bool = false
    @Published var wpm: Double = 0
    @Published var accuracy: Double = 0
    @Published var correctLockerIndex: Int = Int.random(in: 0..<9)
    @Published var timerDisplay: String = "1:00"
    @Published var hasError: Bool = false

    private var startTime: Date?
    private var timeRemaining: Int = 60
    private var timer: Timer?
    var shakeCount: Int = 0

    let texts = [
        // "The quick brown fox jumps over the lazy dog. This text could randomly jump, disappear, and ads also could randomly show up to annoy you while you're trying to type.",
        "Lorem ipsum"
    ]

    init() { newSession() }

    func newSession() {
        stopTimer()
        correctLockerIndex = Int.random(in: 0..<9)
        currentText = texts.randomElement()!
        typedText = ""
        mistakeCount = 0
        isShaking = false
        sessionEnded = false
        wpm = 0
        accuracy = 0
        startTime = nil
        shakeCount = 0
        timeRemaining = 60
        timerDisplay = "1:00"
        hasError = false
    }

    func onTextInput(_ input: String) {
        guard !sessionEnded else { return }
        if startTime == nil { startTime = Date() }

        typedText = input

        if currentText.hasPrefix(input) {
            hasError = false
            if input == currentText { endSession() }
        } else {
            hasError = true
            mistakeCount += 1
        }
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.timeRemaining -= 1
            let mins = self.timeRemaining / 60
            let secs = self.timeRemaining % 60
            self.timerDisplay = String(format: "%d:%02d", mins, secs)
            if self.timeRemaining <= 0 { self.endSession() }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func onKeyPress(_ char: String) {
        guard !sessionEnded else { return }
        if startTime == nil { startTime = Date() }

        let index = typedText.count
        guard index < currentText.count else { return }

        let expected = String(currentText[currentText.index(currentText.startIndex, offsetBy: index)])

        if char == expected {
            typedText += char
            shakeCount = 0
            if typedText == currentText { endSession() }
        } else {
            mistakeCount += 1
            shakeCount += 1
            triggerShake()
        }
    }

    private func triggerShake() {
        isShaking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.isShaking = false
        }
    }

    private func endSession() {
        guard !sessionEnded else { return }
        stopTimer()
        if let start = startTime {
            let elapsed = Date().timeIntervalSince(start) / 60
            let wordCount = Double(currentText.split(separator: " ").count)
            wpm = elapsed > 0 ? (wordCount / elapsed).rounded() : 0
        }
        let totalChars = Double(currentText.count)
        accuracy = totalChars > 0 ? ((totalChars - Double(mistakeCount)) / totalChars * 100).rounded() : 0
        sessionEnded = true
        saveSession()
    }

    func passiveComment() -> String {
        let previous = previousBestWpm()
        if accuracy < 70 { return "you type like you're thinking too hard." }
        if wpm < (previous ?? wpm + 1) { return "slower than last time." }
        if mistakeCount > 10 { return "this is what you practiced for?" }
        if wpm > (previous ?? 0) { return "finally." }
        return "good enough, i guess."
    }

    func rankLabel() -> String {
        if wpm < 50 { return "low" }
        if wpm < 80 { return "avg" }
        return "top"
    }

    func cardColor() -> Color {
        if wpm < 50 { return Color(hex: "#FDECEA") }
        if wpm < 80 { return Color(hex: "#D4E8C2") }
        return Color(hex: "#D6E4F7")
    }

    private func saveSession() {
        var history = loadHistory()
        history.append(["wpm": wpm, "accuracy": accuracy, "date": Date().timeIntervalSince1970])
        if let data = try? JSONSerialization.data(withJSONObject: history) {
            UserDefaults.standard.set(data, forKey: "remain_history")
        }
    }

    func previousBestWpm() -> Double? {
        loadHistory().compactMap { $0["wpm"] }.max()
    }

    private func loadHistory() -> [[String: Double]] {
        guard let data = UserDefaults.standard.data(forKey: "remain_history"),
              let history = try? JSONSerialization.jsonObject(with: data) as? [[String: Double]]
        else { return [] }
        return history
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
