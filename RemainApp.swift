//
//  RemainApp.swift
//  Remain
//
//  Created by Sayyidah Fatimah Azzahra on 25/03/26.
//

import SwiftUI
import CoreText

@main
struct RemainApp: App {
    init() {
        if let url = Bundle.main.url(forResource: "FingerPaint-Regular", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 520, height: 560)
    }
}
