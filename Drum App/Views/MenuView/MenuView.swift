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
    let menuWidth = UIScreen.main.bounds.width * 0.6
    let menuHeight = UIScreen.main.bounds.height * 0.6
    
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
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: menuWidth, height: menuHeight)
                        .cornerRadius(10)
                    
                    switch viewModel.currentMenu {
                    case .home:
                        HomeMenuView(viewModel: viewModel, currentView: $currentView, menuWidth: menuWidth, menuHeight: menuHeight, isMenuVisible: $isMenuVisible, isCountVisible: $isCountVisible)
                    case .changeBPM:
                        ChangeBPMMenuView(viewModel: viewModel, customScene: $customScene, bpmDisplay: $bpmDisplay, menuWidth: menuWidth)
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

struct HomeMenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    @Binding var currentView: AppView
    let menuWidth: CGFloat
    let menuHeight: CGFloat
    @Binding var isMenuVisible: Bool
    @Binding var isCountVisible: Bool
    
    var body: some View {
        VStack {
            Button(action: { currentView = .home }) {
                Text("Main Menu")
            }
            .frame(width: menuWidth * 0.95, height: menuHeight / 5)
            .background(Color.blue)
            .foregroundColor(.white)
            
            Button(action: { viewModel.currentMenu = .settings }) {
                Text("Settings")
            }
            .frame(width: menuWidth * 0.95, height: menuHeight / 5)
            .background(Color.blue)
            .foregroundColor(.white)
            
            Button(action: { viewModel.currentMenu = .changeBPM }) {
                Text("Change BPM")
            }
            .frame(width: menuWidth * 0.95, height: menuHeight / 5)
            .background(Color.blue)
            .foregroundColor(.white)
            
            Button(action: {
                isMenuVisible = false
                isCountVisible = true
            }) {
                Text("Close")
            }
            .frame(width: menuWidth * 0.95, height: menuHeight / 5)
            .background(Color.blue)
            .foregroundColor(.white)
        }
    }
}

struct ChangeBPMMenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    @Binding var customScene: MidiScene
    @Binding var bpmDisplay: Double
    let menuWidth: CGFloat
    
    var body: some View {
        VStack {
            Text("BPM: \(Int(bpmDisplay))")
                .font(.headline)
            
            Slider(value: $bpmDisplay, in: 10...240)
                .frame(width: 200)  // adjust this value as needed
            
            Button(action: {
                viewModel.changeBPM(to: bpmDisplay, customScene: customScene)
            }) {
                Text("Looks Good!")
            }
        }
    }
}

struct SettingsMenuView: View {
    var body: some View {
        EmptyView()
    }
}
