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

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Color.black.opacity(0.8)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                Text("\(counter)")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
            )
            .onReceive(timer) { _ in
                if counter > 0 {
                    counter -= 1
                } else {
                    timer.upstream.connect().cancel()  // Stop the timer when countdown is over
                    customScene.isPaused = false
                    show = false
                }
            }
    }
}
