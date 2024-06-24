//
//  CountdownView.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import SwiftUI

struct CountdownView: View {
    @Binding var show: Bool
    @Binding var customScene: MidiScene
    @State private var counter = 3
    @State private var displayText: String = "3"

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Color.white.opacity(0.5)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                TextImageView(text: $displayText, font: "game")
            )
            .onReceive(timer) { _ in
                if counter > 0 {
                    displayText = "\(counter)"
                    counter -= 1
                } else {
                    timer.upstream.connect().cancel()
                    customScene.isPaused = false
                    show = false
                }
            }
    }
}
