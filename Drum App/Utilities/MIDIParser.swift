//
//  MIDIParser2.swift
//  Drum App
//
//  Created by Oliver Li on 7/16/23.
//

import Foundation

let DRUM_KEY_START = 35
let DRUM_KEY_END = 81

// MidiNote
struct MidiNote {
    var nKey: UInt8 = 0
    var nVelocity: UInt8 = 0
    var nStartTime: UInt32 = 0
    var nDuration : UInt32?
    var xPos : Float?
    var yPos : Float?
}

struct MidiSong {
    var m_nTempo : UInt32 = 500_000
    var m_nBPM : UInt32 = 120
    var song : [MidiNote] = []
    var instruments = Set<UInt8>()
    var nNum : UInt8 = 4
    var nDenom : UInt8 = 4
    var nMetro : UInt8 = 24
    var n32nds : UInt8 = 8
    var nTickLength : Double = 500_000 / 60
}

class MidiFile {
    var noteProcesser: [MidiNote?] = Array(repeating: nil, count: DRUM_KEY_END-DRUM_KEY_START+1)
    let inputStream: BackwardReadableStream

    init?(file_name: String) {
        guard let inStream = BackwardReadableStream(file_name: file_name) else {
            print("Unable to open input file")
            return nil
        }
        
        self.inputStream = inStream
    }

    init?(file_url: URL) {
        guard let inStream = BackwardReadableStream(file_url: file_url) else {
            print("Unable to open input file")
            return nil
        }
        
        self.inputStream = inStream
    }
    
    public func parseFile() throws -> MidiSong {
        func readVarLength () throws -> UInt32 {
            var buffer8 : UInt8 = 0
            var buffer32 : UInt32 = 0

            // grab the first byte
            buffer8 = try inputStream.read8()
            buffer32 = UInt32(buffer8)
            
            // if the first bit is 1, we continue
            // if the first bit is 0, we end
            if(buffer8 & 0x80 == 0x80){
                // keep the last 7 digits only
                buffer32 &= 0x7F
                repeat {
                    // read the next byte in
                    buffer8 = try inputStream.read8()
                    
                    //add the next 7 bits in
                    buffer32 <<= 7
                    buffer32 |= UInt32(buffer8 & 0x7F)
                // repeat while the new byte has a 1 in first bit location
                } while (buffer8 & 0x80 == 80)
            }
            return buffer32
        }
            
        func readString (nLength: UInt32) throws -> String {
            var text : String = "";
            for _ in 0..<nLength {
                text.append(Character(UnicodeScalar(try inputStream.read8())))
            }
            return text
        }
        
        var midiSong = MidiSong()
        let nFileID : UInt32 = try inputStream.read32()
        let nHeaderLength : UInt32 = try inputStream.read32()
        let nFormat : UInt16 = try inputStream.read16()
        let nTrackChunks : UInt16 = try inputStream.read16()
        
        var divisionHelper : UInt16 = try inputStream.read16()
        
//        // for now just work with one track
//        assert(nFormat == 0, "All percussion should be on 1 track")
//        assert(nTrackChunks == 1, "All percussion should be on 1 track")
        
        
        var firstNote : Bool = true
        for nChunk in 0..<nTrackChunks {
            var wallTime : UInt32 = 0
            var nTrackID : UInt32 = try inputStream.read32()
            var nTrackLength : UInt32 = try inputStream.read32()
            
            var bEndOfTrack : Bool = false
            
            var nPreviousStatus : UInt8 = 0
            
            while(inputStream.hasBytesAvailable() && !bEndOfTrack) {
                var nStatus : UInt8 = 0
                
                wallTime += try readVarLength()
                nStatus = try inputStream.read8()
                
                if (nStatus < 0x80) {
                    nStatus = nPreviousStatus
                    inputStream.undoByte()
                }
                
                var nEvent = nStatus & 0xF0
                
                switch nEvent {
                // Note Off
                case 0x80:
                    nPreviousStatus = nStatus
                    var nChannel : UInt8 = nStatus & 0x0F
                    var nNoteID : UInt8 = try inputStream.read8()
                    var nNoteVelocity : UInt8 = try inputStream.read8()
                    
                    if nChannel != UInt8(9) {
                        continue
                    }
                    
                    if (Int(nNoteID) > DRUM_KEY_END || Int(nNoteID) < DRUM_KEY_START) {
                        break
                    }
                    
                    if noteProcesser[Int(nNoteID) - DRUM_KEY_START] != nil{
                        noteProcesser[Int(nNoteID) - DRUM_KEY_START]!.nDuration = wallTime - (noteProcesser[Int(nNoteID) - DRUM_KEY_START]!.nStartTime)
                    }
                // Note On
                case 0x90:
                    nPreviousStatus = nStatus
                    let nChannel : UInt8 = nStatus & 0x0F
                    let nNoteID : UInt8 = try inputStream.read8()
                    let nNoteVelocity : UInt8 = try inputStream.read8()
                    
                    if nChannel != UInt8(9) {
                        continue
                    }
                    
                    if (Int(nNoteID) > DRUM_KEY_END || Int(nNoteID) < DRUM_KEY_START) {
                        break
                    }
                    
                    if firstNote {
                        firstNote = false
                        wallTime = 0
                    }
                                        
                    // currNote refers to noteProcesser[Int(nNoteID) - 34] for brevity
                    // if note Velocity is 0, then treat as a note off event
                    if (nNoteVelocity == 0){
                        // only proceed if currNote exists
                        if noteProcesser[Int(nNoteID) - DRUM_KEY_START] != nil{
                            noteProcesser[Int(nNoteID) - DRUM_KEY_START]!.nDuration = wallTime - (noteProcesser[Int(nNoteID) - DRUM_KEY_START]!.nStartTime)
                            midiSong.song.append(noteProcesser[Int(nNoteID) - DRUM_KEY_START]!)
                            noteProcesser[Int(nNoteID) - DRUM_KEY_START] = nil
                        }
                        break
                    }
                    
                    // at this point, Velocity must be non-zero
                    // take care of edge case of non-zero velocity but a note is already in processing
                    if noteProcesser[Int(nNoteID) - DRUM_KEY_START] != nil{
                        noteProcesser[Int(nNoteID) - DRUM_KEY_START]!.nDuration = wallTime - (noteProcesser[Int(nNoteID) - DRUM_KEY_START]!.nStartTime ?? 0)
                        midiSong.song.append(noteProcesser[Int(nNoteID) - DRUM_KEY_START]!)
                    }
                    
                    // at this point, Velocity is non-zero and currNote is nil
                    noteProcesser[Int(nNoteID) - DRUM_KEY_START] = MidiNote(nKey: nNoteID, nVelocity: nNoteVelocity, nStartTime: wallTime, nDuration: nil)
                    midiSong.instruments.insert(nNoteID)
                    
                // After Touch
                case 0xA0:
                    nPreviousStatus = nStatus
                    var nChannel : UInt8 = nStatus & 0x0F
                    var nNoteID : UInt8 = try inputStream.read8()
                    var nNoteVelocity : UInt8 = try inputStream.read8()
                // Control Change
                case 0xB0:
                    nPreviousStatus = nStatus
                    var nChannel : UInt8 = nStatus & 0x0F
                    var nNoteID : UInt8 = try inputStream.read8()
                    var nNoteVelocity : UInt8 = try inputStream.read8()
                // Program Change
                case 0xC0:
                    nPreviousStatus = nStatus
                    var nChannel : UInt8 = nStatus & 0x0F
                    var nProgramID : UInt8 = try inputStream.read8()
                // Channel Pressure
                case 0xD0:
                    nPreviousStatus = nStatus
                    var nChannel : UInt8 = nStatus & 0x0F
                    var nAmount : UInt8 = try inputStream.read8()
                // Pitch Bend
                case 0xE0:
                    nPreviousStatus = nStatus
                    var nChannel : UInt8 = nStatus & 0x0F
                    var nLSB : UInt8 = try inputStream.read8()
                    var nMSB : UInt8 = try inputStream.read8()
                // System Exclusive
                case 0xF0:
                    nPreviousStatus = 0
                    if (nStatus == 0xFF) {
                        var nType : UInt8 = try inputStream.read8()
                        var nLength : UInt32 = try readVarLength()
                        switch nType {
                        // Sequence Number
                        case 0x00:
                            var nMSB : UInt8 = try inputStream.read8()
                            var nLSB : UInt8 = try inputStream.read8()
                        // Text Event
                        case 0x01:
                            var text : String = try readString(nLength: nLength)
                        // Copyright Notice
                        case 0x02:
                            var text : String = try readString(nLength: nLength)
                        // Sequence/Track Name
                        case 0x03:
                            var text : String = try readString(nLength: nLength)
                        // Instrument Name
                        case 0x04:
                            var text : String = try readString(nLength: nLength)
                        // Lyrics
                        case 0x05:
                            var text : String = try readString(nLength: nLength)
                        // Marker
                        case 0x06:
                            var text : String = try readString(nLength: nLength)
                        // Cue point
                        case 0x07:
                            var text : String = try readString(nLength: nLength)
                        // MIDI Channel Prefix
                        case 0x20:
                            var nChannel : UInt8 = try inputStream.read8()
                        case 0x21:
                            var nPort : UInt8 = try inputStream.read8()
                        // End of Track
                        case 0x2F:
                            bEndOfTrack = true
                        // Set Tempo
                        case 0x51:
                            if (midiSong.m_nTempo == 0)
                            {
                                midiSong.m_nTempo |= (UInt32(try inputStream.read8()) << 16)
                                midiSong.m_nTempo |= (UInt32(try inputStream.read8()) << 8)
                                midiSong.m_nTempo |= UInt32(try inputStream.read8())
                                midiSong.m_nBPM = (60000000 / midiSong.m_nTempo)
                            }
                        // SMPTE Offset
                        case 0x54:
                            var nHourandFrame : UInt8 = try inputStream.read8()
                            var nMin : UInt8 = try inputStream.read8()
                            var nSec : UInt8 = try inputStream.read8()
                            var nSubFrame : UInt8 = try inputStream.read8()
                        // Time Signature
                        case 0x58:
                            midiSong.nNum = try inputStream.read8()
                            midiSong.nDenom = try inputStream.read8()
                            midiSong.nMetro = try inputStream.read8()
                            midiSong.n32nds = try inputStream.read8()
                        // Key Signature
                        case 0x59:
                            try inputStream.read8()
                            try inputStream.read8()
                        // Sequence Specific
                        case 0x7F:
                            try readString(nLength: nLength)
                        default:
                            print("Error has Occured, 1")
                            print(nStatus)
                            print(nType)
                        }
                    } else if (nStatus == 0xF0) {
                        try readString(nLength: try readVarLength())
                    } else if (nStatus == 0xF7) {
                        try readString(nLength: try readVarLength())
                    }
                default:
                    print("Error has Occured, 2")
                    print(nEvent)
                }
            }
        }
                
        // make sure no notes are left processing
        for i in noteProcesser.indices {
            if noteProcesser[i] != nil {
                midiSong.song.append(noteProcesser[i]!)
            }
        }
        
        midiSong.song.sort { $0.nStartTime < $1.nStartTime }
        
        // ticks per beat
        if divisionHelper & 0x8000 == 0x0000 {
            divisionHelper &= 0x7fff
            midiSong.nTickLength = Double(midiSong.m_nTempo) / Double(divisionHelper)
        // frames per second
        } else {
            midiSong.nTickLength = 1_000_000 / Double(((divisionHelper & 0x7f00) * (divisionHelper & 0x00ff)))
        }

        return midiSong
    }
    
}
