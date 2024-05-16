//
//  LoadingViewModel.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import SwiftUI

final class LoadingViewModel : ObservableObject
{
    @Binding var currentView: AppView
    @Binding var midiData: MidiFile?
    @Binding var documentURL: URL?
    @Binding var midiSong: MidiSong?
    @Published var alertItem: AlertItem?

    init(currentView: Binding<AppView>, midiData: Binding<MidiFile?>, documentURL: Binding<URL?>, midiSong: Binding<MidiSong?>)
    {
        self._currentView = currentView
        self._midiData = midiData
        self._documentURL = documentURL
        self._midiSong = midiSong
    }

    func processMidi()
    {
        guard let url = documentURL else
        {
            alertItem = AlertContext.invalidURL
            return
        }
        midiData = MidiFile(file_url: url)
    }
    
    func parseMidi()
    {
        guard let midiFile = midiData else
        {
            alertItem = AlertContext.processingError
            return
        }
        do
        {
            midiSong = try midiFile.parseFile()
            if midiSong == nil
            {
                alertItem = AlertContext.processingError
            }
            else
            {
                currentView = .game
            }
        }
        catch
        {
            alertItem = AlertContext.processingError
        }
    }

    func loadData()
    {
        alertItem = nil
        processMidi()
        parseMidi()
        if alertItem != nil
        {
            currentView = .home
        }
    }
}
