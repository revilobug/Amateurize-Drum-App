//
//  MenuView.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import SwiftUI

struct MenuView : View {
    enum MenuState {
        case home
        case mainMenu
        case settings
        case changeBPM
    }

    @State private var currentMenu : MenuState = .home
    @State var newBPM : Float = 0.0
    @Binding var customScene: MidiScene
    @Binding var isMenuVisible : Bool
    @Binding var isCountVisible : Bool
    @Binding var currentView: AppView
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        VStack {
            Spacer()
            HStack{
                Spacer()
                ZStack{
                    Rectangle()
                        .fill(.white)
                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.6)
                        .cornerRadius(10)
                    switch currentMenu {
                    case .home:
                    VStack{
                        Button (action: {currentView = .home}) {Text("Main Menu")}
                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.1)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        Button (action: {currentMenu = .settings}) {Text("Settings")}
                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.1)
                        .background(Color.blue)
                        .foregroundColor(.white)

                        Button (action: {currentMenu = .changeBPM}) {Text("Change BPM")}
                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.1)
                        .background(Color.blue)
                        .foregroundColor(.white)

                        Button(action: {
                            isMenuVisible = false
                            isCountVisible = true
                        }) {Text("Close")}
                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.1)
                        .background(Color.blue)
                        .foregroundColor(.white)
                    }
                    case .changeBPM:
                    VStack{
                        Text("BPM: \(Int(newBPM))")
                            .font(.headline)

                        Slider(value: $newBPM, in: 10...240)
                            .frame(width: 200)  // adjust this value as needed
                        Button (action: {
                            customScene.changeBPM(newBPM: UInt32(newBPM))
                            currentMenu = .home
                        }) {Text("Looks Good!")}
                    }
                    case .mainMenu:
                        EmptyView()
                    case .settings:
                        EmptyView()
                    }
                }
                Spacer()
            }
            Spacer()
        }
    }
}

