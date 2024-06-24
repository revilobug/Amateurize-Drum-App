//
//  MenuView.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import SwiftUI

class MenuViewModel: ObservableObject {
    enum MenuState {
        case home
        case settings
        case changeBPM
    }
    
    @Published var currentMenu: MenuState = .home
    
    func changeBPM(to newBPM: Double, customScene: MidiScene) {
        customScene.changeBPM(newBPM: UInt32(newBPM))
        currentMenu = .home
    }
}

struct MenuView: View {
    @ObservedObject private var viewModel: MenuViewModel
    
    @Binding var customScene: MidiScene
    @Binding var isMenuVisible: Bool
    @Binding var isCountVisible: Bool
    @Binding var currentView: AppView
    @State var bpmDisplay: Double
    
    init(customScene: Binding<MidiScene>,
         isMenuVisible: Binding<Bool>,
         isCountVisible: Binding<Bool>,
         currentView: Binding<AppView>) {
        self._customScene = customScene
        self._isMenuVisible = isMenuVisible
        self._isCountVisible = isCountVisible
        self._currentView = currentView
        self.viewModel = MenuViewModel()
        self._bpmDisplay = State(initialValue: Double(customScene.wrappedValue.bpm))
    }
    
    var body: some View {
        ZStack{
            Color.white.opacity(0.5)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        Image("smaller-menu")
                        
                        switch viewModel.currentMenu {
                        case .home:
                            HomeMenuView(viewModel: viewModel, currentView: $currentView, isMenuVisible: $isMenuVisible, isCountVisible: $isCountVisible)
                        case .changeBPM:
                            ChangeBPMMenuView(viewModel: viewModel, customScene: $customScene, bpmDisplay: $bpmDisplay)
                        case .settings:
                            SettingsMenuView()
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct HomeMenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    @Binding var currentView: AppView
    @Binding var isMenuVisible: Bool
    @Binding var isCountVisible: Bool
    @State private var isFlickering = false
    
    var body: some View {
        VStack {
            Image("paused").padding(.top, 10)            
                .opacity(isFlickering ? 0.3 : 1.0) // Change opacity between 0.1 and 1.0
                .onAppear {
                    // Create a Timer that toggles the flickering effect
                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
                        isFlickering.toggle() // Toggle the flickering state
                    }
                }

            Button(action: { currentView = .home }) {
                ZStack{
                    Image("b-home")
                }
            }
                        
            Button(action: { viewModel.currentMenu = .changeBPM }) {
                ZStack{
                    Image("b-bpm")
                }
            }
            
            Button(action: {
                isMenuVisible = false
                isCountVisible = true
            }) {
                ZStack{
                    Image("b-close")
                }
            }
        }
    }
}

struct ChangeBPMMenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    @Binding var customScene: MidiScene
    @Binding var bpmDisplay: Double
    @State private var displayText: String = ""
    
    var body: some View {
        VStack {
            TextImageView(text: $displayText, font: "game")
                .padding(.top, 20)
                .padding(.bottom, 20)
            

            Slider(value: $bpmDisplay, in: 10...240)
                .frame(width: 200)
                .onChange(of: bpmDisplay) { newValue in
                    displayText = "BPM: \(Int(newValue))"
                }                
                .padding(.bottom, 10)

            
            Button(action: {
                viewModel.changeBPM(to: bpmDisplay, customScene: customScene)
            }) {
                Image("b-ok!")
            }
            .onAppear {
                // Set displayText based on the initial value of bpmDisplay when the view appears
                displayText = "BPM: \(Int(bpmDisplay))"
            }
        }
    }
}

struct SettingsMenuView: View {
    var body: some View {
        EmptyView()
    }
}
