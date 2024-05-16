//
//  LoadingView.swift
//  Drum App
//
//  Created by Oliver Li on 8/12/23.
//

import SwiftUI

struct LoadingView: View {
    @ObservedObject private var viewModel: LoadingViewModel
    
    init(currentView: Binding<AppView>, 
         midiData: Binding<MidiFile?>,
         documentURL: Binding<URL?>,
         midiSong: Binding<MidiSong?>)
    {
        self.viewModel = LoadingViewModel(currentView: currentView, 
                                          midiData: midiData,
                                          documentURL: documentURL,
                                          midiSong: midiSong)
    }
    
    var body: some View 
    {
        VStack 
        {
            Text("Loading...")
                .background(Color.red)
                .onAppear 
                {
                    viewModel.loadData()
                }
        }
        .alert(item: $viewModel.alertItem) 
        { 
            alertItem in
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: alertItem.dismissButton)
        }
    }
}
