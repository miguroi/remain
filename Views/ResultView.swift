//
//  ResultView.swift
//  Remain
//
//  Created by Sayyidah Fatimah Azzahra on 25/03/26.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var state: GameState
    let onAgain: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Image("background3")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            HStack(alignment: .center, spacing: 0) {
                VStack(spacing: 20) {
                    ZStack(alignment: .topLeading) {
                        Image("reportcard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 350)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 20) {
                StatRow(value: "\(Int(state.wpm))")
                StatRow(value: "\(Int(state.accuracy))%")
                StatRow(value: "\(state.mistakeCount)")
            }.offset(CGSize(width: 150, height: 20))
            
            Text("\(state.passiveComment())")
                .font(.custom("FingerPaint-Regular", size: 25))
                .foregroundColor(Color(hex: "#FFFFFF"))
                .padding(.top, 450)
            
            Image("backbox")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .onTapGesture {
                    onClose()
                }
                .padding(.top, 630)
        }
    }
}

struct StatRow: View {
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Text(value)
                .font(.custom("FingerPaint-Regular", size: 25))
                .foregroundColor(Color(hex: "#1A1A1A"))
        }
    }
}

//#Preview {
//    ResultView(state: GameState(), onAgain: {}, onClose: {})
//}
