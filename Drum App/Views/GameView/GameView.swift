//
//  GameView.swift
//  Drum App
//
//  Created by Oliver Li on 8/21/23.
//

import Foundation
import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var isMenuVisible : Bool
    @State private var isCountVisibile : Bool
    @State var customScene : MidiScene
    @Binding var currentView: AppView

    init (currentView: Binding<AppView>, midiData: MidiSong)
    {
        self.isMenuVisible = false
        self.isCountVisibile = true
        self.customScene = MidiScene(song: midiData.song,
                                     bpm: midiData.m_nBPM,
                                     tickLength: midiData.nTickLength)
        self._currentView = currentView
    }

    var body: some View
    {
        ZStack (alignment: .center)
        {
            VStack
            {
                HStack
                {
                    Button(action: {isMenuVisible.toggle()})
                    {
                        Image("pause")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width:60, height: 60)
                    }.padding(.top, 20).padding(.leading, 20).edgesIgnoringSafeArea(.all)
                    Spacer()
                }
                Spacer()
            }

            .background(
                ZStack
                {
                    Image("game-backdrop1")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                    SpriteView(scene: customScene, options: [.allowsTransparency])
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all)
                }
            )
            if isMenuVisible
            {
                MenuView(newBPM: Float(customScene.bpm), customScene: $customScene, isMenuVisible: $isMenuVisible, isCountVisible: $isCountVisibile, currentView: $currentView).onAppear{customScene.isPaused = true}
            }
            if isCountVisibile
            {
                CountdownView(show: $isCountVisibile, customScene: $customScene).onAppear{customScene.isPaused = true}
            }
        }
    }
}
