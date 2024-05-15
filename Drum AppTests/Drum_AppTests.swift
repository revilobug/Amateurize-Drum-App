//
//  Drum_AppTests.swift
//  Drum AppTests
//
//  Created by Oliver Li on 7/13/23.
//

import XCTest
import Foundation
@testable import Drum_App

class Drum_AppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
//    func testBinaryParse () {
//        let file_name = "/Users/oliverli/code/Drum App/Smells_Like_Teen_Spirit_.mid"
//
//        let parser = MidiFile(file_name: file_name)
//
//        let results = parser.parseFile()
//
//        XCTAssert(results)
//    }
    
    func testBuffer() {
        // Get the url for Smells_Like_Teen_Spirit_.mid file in the test bundle
        let testBundle = Bundle(for: type(of: self))
        guard let fileURL = testBundle.url(forResource: "Smells_Like_Teen_Spirit_", withExtension: "mid") else {
            XCTFail("Unable to find the MIDI file in the test bundle")
            return
        }
      
        // Create a MidiFile instance with the URL
        guard let midiParser = MidiFile(file_url: fileURL) else {
            XCTFail("Unable to create MidiFile instance")
            return
        }
      
        do {
            let parseResult = try midiParser.parseFile()
            XCTAssertTrue(parseResult, "File parsing failed.")
        } catch {
            XCTFail("Error: \(error)")
        }
    }
    
    func testBinary () {
        let testBundle = Bundle(for: type(of: self))
        guard let fileURL = testBundle.url(forResource: "Smells_Like_Teen_Spirit_", withExtension: "mid") else {
            XCTFail("Unable to find the MIDI file in the test bundle")
            return
        }

        guard let inputStream = BackwardReadableStream(file_url:fileURL) else {
            XCTFail("Unable to create MidiFile instance")
            return
        }

        var buffer : UInt8 = 0

        // Output file will be written to the desktop
        let outputUrl = URL(fileURLWithPath: "/Users/oliverli/code/output.txt")

        var outputText = ""

        while inputStream.hasBytesAvailable() {
            do {
                buffer = try inputStream.read8()
            } catch {
                XCTFail("Error: \(error)")
            }
            let hexString = String(format: "0x%02x, ", buffer)
            outputText.append(hexString)
        }

        do {
            try outputText.write(to: outputUrl, atomically: true, encoding: .utf8)
            print("File written to: \(outputUrl.path)")
        } catch {
            XCTFail("Failed to write to file: \(error)")
        }
    }

    func testWrapper() {
        let testBundle = Bundle(for: type(of: self))
        guard let fileURL = testBundle.url(forResource: "Smells_Like_Teen_Spirit_", withExtension: "mid") else {
            XCTFail("Unable to find the MIDI file in the test bundle")
            return
        }
        
        guard let inputStream = BackwardReadableStream(file_url:fileURL) else {
            XCTFail("Unable to create MidiFile instance")
            return
        }
                
        var buffer : UInt8 = 0
        
        while inputStream.hasBytesAvailable() {
            do {
                buffer = try inputStream.read8()
            }
            catch {
                XCTFail("Error: \(error)")
            }
            print(buffer)
        }
    }
}
