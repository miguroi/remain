//
//  TypingView.swift
//  Remain
//
//  Created by Sayyidah Fatimah Azzahra on 25/03/26.
//

// Virus View
// Rickrolled View
// Ads View
// Bee View

import SwiftUI
import AVKit
import CoreMedia
import AVFoundation

struct TypingView: View {
    @ObservedObject var state: GameState
    let onClose: () -> Void
    
    @FocusState private var isFocused: Bool
    
    @State private var inputText: String = ""
    // @State private var currentMode: Mode = Mode.allCases.filter { $0 != .plain }.randomElement()!
    @State private var currentMode: Mode = .rickrolled
    @State private var videoIsPlaying: Bool = false
    @State private var videoProgress : Double = 0.0
    @State private var videoDuration: Double = 1.0
    @State private var hasStartedTyping: Bool = false
    
    var body: some View {
        ZStack {
            Image("background2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if state.sessionEnded {
                ResultView(state: state, onAgain: {
                    state.newSession()
                    onClose()
                }, onClose: onClose)
                .transition(.opacity)
            } else {
                VStack(spacing: 20) {
                    ZStack(alignment: .topLeading) {
                        Image("textbox")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 560, height: 300)
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                ZStack(alignment: .topLeading) {
                                    Text(state.currentText)
                                        .font(.custom("FingerPaint-Regular", size: 16))
                                        .foregroundColor(Color(hex: "#1A1A1A").opacity(0.3))
                                        .lineSpacing(6)
                                        .frame(width: 496, alignment: .leading)
                                    
                                    typedOverlay
                                        .id("typed")
                                }
                                .padding(32)
                            }
                            .frame(width: 560, height: 240)
                            .scrollDisabled(true)
                            .onChange(of: state.typedText) { _, _ in
                                withAnimation { proxy.scrollTo("typed", anchor: .bottom) }
                            }
                        }
                    }
                    
                    HStack(spacing: 12) {
                        ZStack(alignment: .leading) {
                            Image("inputbox")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 420)
                            
                            TextField("", text: $inputText)
                                .font(.custom("FingerPaint-Regular", size: 16))
                                .foregroundColor(state.hasError ? Color(hex: "#C0392B") : Color(hex: "#1A1A1A"))
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 20)
                                .frame(width: 420)
                                .focused($isFocused)
                                .onChange(of: inputText) { oldValue, newValue in
                                    if state.hasError && newValue.count > oldValue.count {
                                        inputText = oldValue
                                        return
                                    }
                                    if !hasStartedTyping && !newValue.isEmpty {
                                        hasStartedTyping = true
                                        state.startTimer()
                                    }
                                    state.onTextInput(newValue)
                                    if state.sessionEnded { inputText = "" }
                                }
                        }
                        
                        ZStack {
                            Image("timerbox")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 110)
                            
                            Text(state.timerDisplay)
                                .font(.custom("FingerPaint-Regular", size: 16))
                                .foregroundColor(Color(hex: "#1A1A1A"))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .onAppear {
                    isFocused = true
                    // state.startTimer()
                }
                
                overlayFor(mode: currentMode)
                    .zIndex(10)
                
                if currentMode == .rickrolled && videoProgress > 0 {
                    CountdownCircle(
                        progress: videoProgress / videoDuration,
                        secondsLeft: max(0, Int(ceil(videoDuration - videoProgress)))
                    )
                    .frame(width: 80, height: 80)
                    .offset(x: 340, y: 120)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: videoIsPlaying)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.sessionEnded)
    }

    var attributedCurrentText: AttributedString {
        var attributed = AttributedString(state.currentText)
        attributed.foregroundColor = Color(hex: "#1A1A1A").opacity(0.3)
        return attributed
    }
    
    var typedOverlay: some View {
        Text(attributedTypedText)
            .font(.custom("FingerPaint-Regular", size: 16))
            .lineSpacing(6)
    }
        
    var attributedTypedText: AttributedString {
        var attributed = AttributedString(state.typedText)
        
        for (index, char) in state.typedText.enumerated() {
            guard index < state.currentText.count else { break }
            let expected = state.currentText[state.currentText.index(state.currentText.startIndex, offsetBy: index)]
            let range = attributed.index(attributed.startIndex, offsetByCharacters: index)..<attributed.index(attributed.startIndex, offsetByCharacters: index + 1)
            if char != expected {
                attributed[range].foregroundColor = Color(hex: "#C0392B")
            } else {
                attributed[range].foregroundColor = Color(hex: "#1A1A1A")
            }
        }
        return attributed
    }
    
    @ViewBuilder
    func overlayFor(mode: Mode) -> some View {
        switch mode {
        case .plain:
            EmptyView()
        case .virus:
            VirusOverlay(
                currentMode: $currentMode,
                hasStartedTyping: $hasStartedTyping
            )
        case .rickrolled:
            RickrolledOverlay(
                videoIsPlaying: $videoIsPlaying,
                videoProgress: $videoProgress,
                videoDuration: $videoDuration,
                currentMode: $currentMode,
            )
        case .ads:
            AdsOverlay()
        case .bee:
            BeeOverlay()
        }
    }
}

enum Mode: CaseIterable {
    case plain
    case virus
    case rickrolled
    case ads
    case bee
}

struct ModeConfig {
    let mode: Mode
    var animates: Bool
    var interruptsTyping: Bool
}
    
struct VirusOverlay: View {
    @State private var offset: CGSize = .zero
    @State private var timeLeft: Double = 10.0
    @State private var isDodging: Bool = true
    @State private var timer: Timer? = nil
    @Binding var currentMode: Mode
    @Binding var hasStartedTyping: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("virusbox")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)

            Text("You've been infected!")
                .font(.custom("FingerPaint-Regular", size: 30))
                .foregroundColor(Color(hex: "#1A1A1A"))
                .offset(x: -30, y: 160)
            
            HStack(alignment: .bottom, spacing: 0) {
                Text("\(Int(timeLeft))")
                    .font(.custom("FingerPaint-Regular", size: 20))
                    .foregroundColor(Color(hex: "FFFFFF"))
                Text("s")
                    .font(.custom("FingerPaint-Regular", size: 12))
                    .foregroundColor(Color(hex: "FFFFFF"))
                    .offset(y: -2)
            }
            .offset(x: -95, y: 240)

            Color.clear
                .frame(width: 30, height: 20)
                .contentShape(Rectangle())
                .onTapGesture {
                    currentMode = .plain
                }
                .offset(x: -12, y: 120)
        }
        .offset(offset)
        .onHover { isHovering in
            if isHovering && isDodging {
                dodge()
            }
        }
        .onAppear {
        }
        .onChange(of: hasStartedTyping) {_, started in
            if started {
                startCountdown()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func startCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            DispatchQueue.main.async {
                if timeLeft > 0 {
                    timeLeft -= 0.1
                } else {
                    isDodging = false
                    t.invalidate()
                }
            }
        }
    }

    func dodge() {
        let newOffset = CGSize(
            width: CGFloat.random(in: -200...200),
            height: CGFloat.random(in: -200...200)
        )
        withAnimation(.easeOut(duration: 0.3)) {
            offset = newOffset
        }
    }
}

struct RickrolledOverlay: View {
    @State var contentVideo: AVPlayer? = {
        guard let url = Bundle.main.url(forResource: "rickrolled", withExtension: "mp4") else { return nil }
        return AVPlayer(url: url)
    }()
    @Binding var videoIsPlaying: Bool
    @Binding var videoProgress: Double
    @Binding var videoDuration: Double
    @Binding var currentMode: Mode
    @State private var timeObserver: Any? = nil
    @State private var loopCount: Int = 0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("video_box")
                .resizable()
                .scaledToFit()
                .frame(width: 560, height: 480)
            
            VStack(spacing: 4) {
                ZStack {
                    LoopingVideoView(player: contentVideo)
                        .frame(width: 520, height: 240)
                        .clipped()
                    
                    if !videoIsPlaying {
                        Image("video_play")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .onTapGesture {
                                contentVideo?.play()
                                DispatchQueue.main.async { videoIsPlaying = true }
                            }
                    } else {
                        Image("video_pause")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .onTapGesture {
                                contentVideo?.pause()
                                DispatchQueue.main.async { videoIsPlaying = false }
                            }
                    }
                }
                
                ZStack(alignment: .leading) {
                    Image("video_line")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 14)
                    
                    Image("video_circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .offset(x: CGFloat(videoProgress / videoDuration) * (380 - 20))
                }
                .padding(.top, 6)
            }
            .offset(x: -20, y: 110)
            
            if loopCount >= 1 {
                Color.clear
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        currentMode = .plain
                    }
            }
        }
        .onAppear { setupTimeObserver() }
//        .onChange(of: hasStartedTyping) { _, started in
//            if started {
//                contentVideo?.play()
//                videoIsPlaying = true
//            }
//        }
        .onDisappear {
            if let observer = timeObserver {
                contentVideo?.removeTimeObserver(observer)
            }
        }
    }
    
    func setupTimeObserver() {
        guard let contentVideo else { return }
        Task {
            if let item = contentVideo.currentItem {
                let dur = try? await item.asset.load(.duration)
                if let dur, dur.isNumeric {
                    videoDuration = dur.seconds
                }
            }
        }
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = contentVideo.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            videoProgress = time.seconds
            if videoDuration > 0 && time.seconds >= videoDuration - 0.15 {
                if loopCount >= 1 {
                    contentVideo.pause()
                    videoIsPlaying = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        currentMode = .plain
                    }
                } else {
                    contentVideo.seek(to: .zero)
                    if videoIsPlaying {
                        contentVideo.play()
                        loopCount += 1
                    }
                }
            }
        }
    }
}

struct CountdownCircle: View {
    let progress: Double
    let secondsLeft: Int

    var body: some View {
        ZStack {
            Image("video_countdown_circle")
                .resizable()
                .scaledToFit()

            Circle()
                .trim(from: 0, to: CGFloat(1.0 - progress))
                .stroke(
                    Color(hex: "#E74C3C"),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
                .padding(4)

            Text("\(secondsLeft)")
                .font(.custom("FingerPaint-Regular", size: 14))
                .foregroundColor(Color(hex: "#1A1A1A"))
        }
    }
}

class PlayerNSView: NSView {
    var playerLayer: AVPlayerLayer?

    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer?.frame = bounds
        CATransaction.commit()
    }
}

struct LoopingVideoView: NSViewRepresentable {
    let player: AVPlayer?

    func makeNSView(context: Context) -> PlayerNSView {
        let view = PlayerNSView()
        guard let player else { return view }
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.masksToBounds = true
        view.playerLayer = playerLayer
        view.layer = playerLayer
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: PlayerNSView, context: Context) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        nsView.playerLayer?.frame = nsView.bounds
        CATransaction.commit()
    }
}

struct AdsOverlay: View {
    @State private var position1: CGPoint = CGPoint(x: 200, y: 400)
    @State private var position2: CGPoint = CGPoint(x: 100, y: 300)
    @State private var position3: CGPoint = CGPoint(x: 300, y: 200)
    
    var body: some View {
        GeometryReader { geo in
            Image("ad1")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
                .position(position1)
                .onAppear {
                    position1 = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    moveAd1(in: geo.size)
                }
            
            Image("ad2")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
                .position(position2)
                .onAppear {
                    position2 = CGPoint(x: geo.size.width / 3, y: geo.size.height / 3)
                    moveAd2(in: geo.size)
                }
            
            Image("ad3")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
                .position(position3)
                .onAppear {
                    position3 = CGPoint(x: geo.size.width / 4, y: geo.size.height / 4)
                    moveAd3(in: geo.size)
                }
        }
    }
    
    func moveAd1(in size: CGSize) {
        let newPosition = CGPoint(
            x: CGFloat.random(in: 50...size.width - 50),
            y: CGFloat.random(in: 50...size.height - 50)
        )
        withAnimation(.easeInOut(duration: 2.0)) { position1 = newPosition }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { moveAd1(in: size) }
    }
    
    func moveAd2(in size: CGSize) {
        let newPosition = CGPoint(
            x: CGFloat.random(in: 50...size.width - 50),
            y: CGFloat.random(in: 50...size.height - 50)
        )
        withAnimation(.easeInOut(duration: 1.5)) { position2 = newPosition }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { moveAd2(in: size) }
    }
    
    func moveAd3(in size: CGSize) {
        let newPosition = CGPoint(
            x: CGFloat.random(in: 50...size.width - 50),
            y: CGFloat.random(in: 50...size.height - 50)
        )
        withAnimation(.easeInOut(duration: 2.5)) { position3 = newPosition }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { moveAd3(in: size) }
    }
}

struct BeeOverlay: View {
    @State private var position: CGPoint = CGPoint(x: 200, y: 400)
    @State private var angle: Double = Double.random(in: 0...360)
    @State private var displayAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var isRunning = false

    var body: some View {
        GeometryReader { geo in
            Image("bee")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(displayAngle))
                .scaleEffect(x: scale, y: 1.0)
                .position(position)
                .onAppear {
                    position = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    isRunning = true
                    tick(in: geo.size)
                }
                .onDisappear {
                    isRunning = false
                }
        }
    }

    func tick(in size: CGSize) {
        guard isRunning else { return }

        let turnAmount = Double.random(in: -40...40)
        angle += turnAmount

        let stepSize = CGFloat.random(in: 15...40)
        let radians = angle * .pi / 180

        let newX = (position.x + cos(radians) * stepSize)
            .clamped(to: 50...(size.width - 50))
        let newY = (position.y + sin(radians) * stepSize)
            .clamped(to: 50...(size.height - 50))
        let newPosition = CGPoint(x: newX, y: newY)

        let dx = newPosition.x - position.x
        scale = dx >= 0 ? 1.0 : -1.0
        displayAngle = sin(radians) * 15

        withAnimation(.linear(duration: 0.12)) {
            position = newPosition
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            tick(in: size)
        }
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

//#Preview {
//    TypingView(state: GameState(), onClose: { })
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//}
