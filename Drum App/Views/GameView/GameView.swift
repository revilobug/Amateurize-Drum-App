//
//  GameView.swift
//  Drum App
//
//  Created by Oliver Li on 8/21/23.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var isMenuVisible: Bool = false
    @State private var isCountVisible: Bool = true
    @State var customScene: MidiScene
    @Binding var currentView: AppView

    init(currentView: Binding<AppView>, midiData: MidiSong) {
        self.customScene = MidiScene(song: midiData.song, bpm: midiData.m_nBPM, tickLength: midiData.nTickLength)
        self._currentView = currentView
    }

    var body: some View {
        ZStack {
            backgroundLayer
            overlayControls
            menuOverlay
            countdownOverlay
        }
    }

    private var backgroundLayer: some View {
        ZStack {
//            Image("game-backdrop1")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
            Color(red: 0.68, green: 0.85, blue: 0.90)
                .edgesIgnoringSafeArea(.all)
            SpriteView(scene: customScene, options: [.allowsTransparency])
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
        }
    }

    private var overlayControls: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: { isMenuVisible.toggle() }) {
                    Image("pause")
                        .scaleEffect(1.5)
                }
                .padding(.trailing, 10)
                Button(action: { customScene.changeTime(deltaTime: -1) }) {
                    Image("rewind")
                        .scaleEffect(1.5)
                }
                .padding(.trailing, 10)
                Button(action: { customScene.changeTime(deltaTime: 1) }) {
                    Image("skip")
                        .scaleEffect(1.5)
                }
            }
            .padding(.top, 30)
            .padding(.leading, 30)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var menuOverlay: some View {
        Group {
            if isMenuVisible {
                MenuView(customScene: $customScene, isMenuVisible: $isMenuVisible, isCountVisible: $isCountVisible, currentView: $currentView)
                    .onAppear { customScene.isPaused = true }
            }
        }
    }

    private var countdownOverlay: some View {
        Group {
            if isCountVisible {
                CountdownView(show: $isCountVisible, customScene: $customScene)
                    .onAppear { customScene.isPaused = true }
            }
        }
    }
}
