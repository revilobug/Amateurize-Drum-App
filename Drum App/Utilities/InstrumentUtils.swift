//
//  InstrumentUtils.swift
//  Drum App
//
//  Created by Oliver Li on 6/8/24.
//

import Foundation

enum InstrumentType: String {
    case higherPitch = "Higher Pitch"
    case lowerPitch = "Lower Pitch"
    case cymbals = "Cymbals"
    case hiHats = "Hi-Hats"
    case percussion = "Percussion"
    case noInstrumentType = "none"
}

func getInstrumentType(for key: UInt8) -> InstrumentType? {
    let percussionMap: [UInt8: (String, InstrumentType)] = [
        // Higher Pitch
        38: ("Acoustic Snare", .higherPitch),
        40: ("Electric Snare", .higherPitch),
        48: ("Hi Mid Tom", .higherPitch),
        50: ("High Tom", .higherPitch),
        // Lower Pitch
        35: ("Acoustic Bass Drum", .lowerPitch),
        36: ("Bass Drum 1", .lowerPitch),
        41: ("Low Floor Tom", .lowerPitch),
        43: ("High Floor Tom", .lowerPitch),
        45: ("Low Tom", .lowerPitch),
        47: ("Low-Mid Tom", .lowerPitch),
        // Cymbals
        46: ("Open Hi-Hat", .cymbals),
        49: ("Crash Cymbal 1", .cymbals),
        51: ("Ride Cymbal 1", .cymbals),
        52: ("Chinese Cymbal", .cymbals),
        53: ("Ride Bell", .cymbals),
        55: ("Splash Cymbal", .cymbals),
        57: ("Crash Cymbal 2", .cymbals),
        59: ("Ride Cymbal 2", .cymbals),
        // Hi-Hats
        42: ("Closed Hi-Hat", .hiHats),
        44: ("Pedal Hi-Hat", .hiHats),
        // Percussion (combined with others)
        37: ("Side Stick", .percussion),
        39: ("Hand Clap", .percussion),
        54: ("Tambourine", .percussion),
        56: ("Cowbell", .percussion),
        58: ("Vibraslap", .percussion),
        60: ("Hi Bongo", .percussion),
        61: ("Low Bongo", .percussion),
        62: ("Mute Hi Conga", .percussion),
        63: ("Open Hi Conga", .percussion),
        64: ("Low Conga", .percussion),
        65: ("High Timbale", .percussion),
        66: ("Low Timbale", .percussion),
        67: ("High Agogo", .percussion),
        68: ("Low Agogo", .percussion),
        69: ("Cabasa", .percussion),
        70: ("Maracas", .percussion),
        71: ("Short Whistle", .percussion),
        72: ("Long Whistle", .percussion),
        73: ("Short Guiro", .percussion),
        74: ("Long Guiro", .percussion),
        75: ("Claves", .percussion),
        76: ("Hi Wood Block", .percussion),
        77: ("Low Wood Block", .percussion),
        78: ("Mute Cuica", .percussion),
        79: ("Open Cuica", .percussion),
        80: ("Mute Triangle", .percussion),
        81: ("Open Triangle", .percussion)
    ]
    
    return percussionMap[key]?.1
}

func getInstrumentString(for key: UInt8) -> String? {
    let percussionMap: [UInt8: String] = [
        35: "Acoustic Bass Drum",
        36: "Bass Drum 1",
        37: "Side Stick",
        38: "Acoustic Snare",
        39: "Hand Clap",
        40: "Electric Snare",
        41: "Low Floor Tom",
        42: "Closed Hi-Hat",
        43: "High Floor Tom",
        44: "Pedal Hi-Hat",
        45: "Low Tom",
        46: "Open Hi-Hat",
        47: "Low-Mid Tom",
        48: "Hi Mid Tom",
        49: "Crash Cymbal 1",
        50: "High Tom",
        51: "Ride Cymbal 1",
        52: "Chinese Cymbal",
        53: "Ride Bell",
        54: "Tambourine",
        55: "Splash Cymbal",
        56: "Cowbell",
        57: "Crash Cymbal 2",
        58: "Vibraslap",
        59: "Ride Cymbal 2",
        60: "Hi Bongo",
        61: "Low Bongo",
        62: "Mute Hi Conga",
        63: "Open Hi Conga",
        64: "Low Conga",
        65: "High Timbale",
        66: "Low Timbale",
        67: "High Agogo",
        68: "Low Agogo",
        69: "Cabasa",
        70: "Maracas",
        71: "Short Whistle",
        72: "Long Whistle",
        73: "Short Guiro",
        74: "Long Guiro",
        75: "Claves",
        76: "Hi Wood Block",
        77: "Low Wood Block",
        78: "Mute Cuica",
        79: "Open Cuica",
        80: "Mute Triangle",
        81: "Open Triangle"
    ]
    
    return percussionMap[key]
}
