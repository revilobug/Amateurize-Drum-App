//
//  LoadingView.swift
//  Drum App
//
//  Created by Oliver Li on 8/12/23.
//

import SwiftUI

class LoadingViewModel : ObservableObject {
    func processMidi (documentURL: URL) -> MidiFile? {
        return MidiFile(file_url: documentURL)
    }
    
    func parseMidi (midiFile : MidiFile) -> MidiSong? {
        do {
            return try midiFile.parseFile()
        } catch {
            return nil
        }
    }
}

struct LoadingView: View {
    @Binding var currentView: AppView
    @Binding var midiData: MidiFile?
    @Binding var documentURL: URL?
    @Binding var midiSong: MidiSong?
    
    @StateObject var viewModel = LoadingViewModel()
    
    var body: some View {
        Text("Loading!")
            .background(Color.red)
            .onAppear {
                midiData = viewModel.processMidi(documentURL: documentURL.unsafelyUnwrapped)
                midiSong = viewModel.parseMidi(midiFile: midiData!)
                if midiSong == nil {
                    currentView = .home
                } else {
                    currentView = .game
                }
            }
        }
}

//struct LoadingView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoadingView()
//    }
//}
