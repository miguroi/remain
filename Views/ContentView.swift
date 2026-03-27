//
//  ContentView.swift
//  Remain
//
//  Created by Sayyidah Fatimah Azzahra on 25/03/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var state = GameState()
    @State var lockerOpen = false

    let grid = Array(0..<9)

    var body: some View {
        ZStack {
            Image("background1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            if lockerOpen {
                TypingView(state: state, onClose: {
                    lockerOpen = false
                    state.newSession()
                })
                .transition(.opacity)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(120), spacing: -10), count: 3), spacing: 0) {
                    ForEach(grid, id: \.self) { i in
                        LockerCell(
                            isCenter: i == state.correctLockerIndex,
                            locker: Locker.all[i]
                        ) {
                            if i == state.correctLockerIndex {
                                withAnimation { lockerOpen = true }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct Sticker {
    let name: String
    let x: CGFloat
    let y: CGFloat
    let rotation: Double
    let scale: CGFloat
}

struct Locker {
    let stickers: [Sticker]
    
    static let all: [Locker] = [
        // locker 1
        Locker(stickers: [
            Sticker(name: "sticker1", x: -20, y: -47, rotation: -8, scale: 0.28),
            Sticker(name: "sticker2", x: -15, y: -20, rotation: 5, scale: 0.28),
            Sticker(name: "sticker3", x: 0, y: 10, rotation: -3, scale: 0.28),
            Sticker(name: "sticker4", x: 20, y: -30, rotation: 7, scale: 0.36),
            Sticker(name: "sticker5", x: 15, y: 30, rotation: -5, scale: 0.28),
        ]),
        
        // locker 2
        Locker(stickers: [
            Sticker(name: "photo1", x: -20, y: -32, rotation: 10, scale: 0.19),
            Sticker(name: "photo2", x: 10, y: 30, rotation: -10, scale: 0.22)
        ]),
        
        // locker 3
        Locker(stickers: []),
        
        // locker 4
        Locker(stickers: [
            Sticker(name: "pin", x: 20, y: -30, rotation: 0, scale: 0.30),
            Sticker(name: "cherry", x: 5, y: -10, rotation: 0, scale: 0.60)
        ]),
        
        // locker 5
        Locker(stickers: [
            Sticker(name: "scribbles", x: 0, y: -30, rotation: 0, scale: 0.50)
        ]),
        
        // locker 6
        Locker(stickers: [
            Sticker(name: "cat", x: 16, y: 10, rotation: 0, scale: 0.9)
        ]),
        
        // locker 7
        Locker(stickers: [
            Sticker(name: "crack", x: 5, y: -20, rotation: 0, scale: 0.70)
        ]),
        
        // locker 8
        Locker(stickers: [
            Sticker(name: "photostrip", x: 0, y: -30, rotation: 0, scale: 0.60),
            Sticker(name: "sticker7", x: 0, y: -50, rotation: 0, scale: 0.90),
            Sticker(name: "sticker6", x: 5, y: 25, rotation: 0, scale: 0.50)
        ]),
        
        // locker 9
        Locker(stickers: [
            Sticker(name: "cd", x: 5, y: -20, rotation: 0, scale: 0.70)
        ]),
    ]
}

struct LockerCell: View {
    let isCenter: Bool
    let locker: Locker
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Image("plain_locker")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 160)
                    .opacity(isCenter ? 1.0 : 0.85)
                    .clipped()

                ForEach(locker.stickers, id: \.name) { sticker in
                    Image(sticker.name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120 * sticker.scale)
                        .rotationEffect(.degrees(sticker.rotation))
                        .offset(x: sticker.x, y: sticker.y)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}

