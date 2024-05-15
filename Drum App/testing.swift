////
////  testing.swift
////  Drum App
////
////  Created by Oliver Li on 7/26/23.
////
//
//import Foundation
//
//func testFunc() {
//    var buffer8 : UInt8 = 0
//    var buffer32 : UInt32 = 0
//
//    // The following data represents a 32-bit Big Endian integer 0x01020304
//    let hardcodedData = Data([0x01, 0x02, 0x03, 0x04])
//
//    // Creating an InputStream instance
//    var inputStream = InputStream(data: hardcodedData)
//    // Open the inputStream
//    inputStream.open()
//
//    inputStream.read(&buffer8, maxLength: 1)
//    print(buffer8)
//    buffer32 = (UInt32(buffer8) << 24)
//
//
//    inputStream.read(&buffer8, maxLength: 1)
//    print(buffer8)
//    buffer32 |= (UInt32(buffer8) << 16)
//
//
//    inputStream.read(&buffer8, maxLength: 1)
//    print(buffer8)
//    buffer32 |= (UInt32(buffer8) << 8)
//
//
//    inputStream.read(&buffer8, maxLength: 1)
//    print(buffer8)
//    buffer32 |= UInt32(buffer8)
//
//    // Close the inputStream
//    inputStream.close()
//
//    // Verify the result
//    assert(buffer32 == 0x01020304, "The interpretation of the bytes is incorrect")
//
//    print("The bytes were interpreted correctly.")
//    print(buffer32)
//}
//
//func testBuffer() -> Bool{
//    let file_name = "Smells_Like_Teen_Spirit_.mid"
//
//    guard let midiParser = MidiFile(file_name: file_name) else {
//        print("Unable to open input file")
//        return false
//    }
//
//    do {
//        return try midiParser.parseFile()
//        // Code to execute if parsing is successful
//        // (i.e., no error was thrown)
//    } catch {
//        // Code to handle the error if parsing fails
//        // You can log the error, display an error message, or perform any other error handling logic here
//        return false
//    }
//
////    var buffer: UnsafeMutablePointer<UInt8>?
//////    var buffer2 : UInt8 = 0
////    var length: Int = 1
////
//////    let success1 = inputStream.read(&buffer2, maxLength: 1)
////    let success = inputStream.getBuffer(&buffer, length: &length)
////    print(success)
////    print(length)
//////    print(buffer2)
//////    print(success1)
////
////    inputStream.close()
////    print(buffer?.pointee)
//}
