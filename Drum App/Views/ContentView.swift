//
//  ContentView.swift
//  Drum App
//
//  Created by Oliver Li on 7/13/23.
//

import SwiftUI

enum AppView 
{
    case home, loading, game
}

struct ContentView: View 
{
    @State var documentURL : URL?
    @State var currentView: AppView = .home
    @State var midiData: MidiFile?
    @State var midiSong: MidiSong?

    var body: some View 
    {
        Group 
        {
            switch currentView 
            {
                case .home:
                    HomeView(currentView: $currentView, documentURL: $documentURL)
                case .loading:
                    LoadingView(currentView: $currentView, midiData: $midiData, documentURL: $documentURL, midiSong: $midiSong)
                case .game:
                    if let unwrappedMidiData = midiSong 
                    {
                        GameView(currentView: $currentView, midiData: unwrappedMidiData)
                    } 
                    else
                    {
                        // Handle the case where midiData is nil
                        Text("Midi data not available")
                    }
            }
        }
    }
}
