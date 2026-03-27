//
//  KeyPressHandler.swift
//  Remain
//
//  Created by Sayyidah Fatimah Azzahra on 25/03/26.
//

import SwiftUI

struct KeyPressHandler: NSViewRepresentable {
    let onKey: (String) -> Void

    func makeNSView(context: Context) -> KeyView {
        let view = KeyView()
        view.onKey = onKey
        DispatchQueue.main.async { view.window?.makeFirstResponder(view) }
        return view
    }

    func updateNSView(_ nsView: KeyView, context: Context) {}
}

class KeyView: NSView {
    var onKey: ((String) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        guard let chars = event.characters, !chars.isEmpty else { return }
        if event.modifierFlags.contains(.command) { return }
        onKey?(chars)
    }
}
