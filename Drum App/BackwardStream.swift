//
//  File.swift
//  Drum App
//
//  Created by Oliver Li on 7/27/23.
//

import Foundation

enum BackwardReadableStreamError: Error {
    case notEnoughBytesToRead
}

class BackwardReadableStream {
    private let inStream: InputStream

    // stores 4 bytes
    private var cache : [UInt8?]
    // start off at 4
    private var readPointer : Int
    private let history_len : UInt8

    init?(file_name: String, history_len: UInt8 = 4) {
        guard let inputStream = InputStream(fileAtPath: file_name) else {
            print("Unable to open input file")
            return nil
        }
        
        self.inStream = inputStream
        self.inStream.open()
        self.history_len = history_len
        cache = Array(repeating: nil, count: Int(self.history_len) + 4)
        readPointer = cache.count
        updateCache()
        
    }
    
    init?(file_url: URL, history_len: UInt8 = 4) {
        guard let inputStream = InputStream(url: file_url) else {
            print("Unable to open input file")
            return nil
        }
        
        self.inStream = inputStream
        self.inStream.open()
        self.history_len = history_len
        cache = Array(repeating: nil, count: Int(self.history_len) + 4)
        readPointer = cache.count
        updateCache()
    }
    
    deinit {
        self.inStream.close()
    }
    
    func updateCache() {
        // check how many bytes we need to read to return readPointer to 4
        let bytesToRead : Int = readPointer - Int(history_len)
        var buffer8 : UInt8 = 0

        // if bytesToRead is less than or equal to 0, we don't need to do anything
        guard bytesToRead > 0 else {
            return
        }
        
        // iterate bytesToRead number of times
        for _ in 0 ..< bytesToRead {
            // exit if no bytes left
            if !self.inStream.hasBytesAvailable {
                return
            }
            
            // to double check that bytes are being read
            var check : Int = 0
            
            // read a byte
            check = self.inStream.read(&buffer8, maxLength: 1)
            
            // make sure that a byte was read
            if check == 1 {
                // add the newly read element to back of cache
                cache.append(buffer8)
                // remove an element from front of cache (cache history)
                cache.removeFirst()
                // move the readPointer so that it still refers to the same relative value/place
                readPointer -= 1
            } else {
                // if the read failed, exit
                return
            }
        }
    }
    
    func undoByte() -> Bool{
        // make sure readPointer is greater than 0
        guard readPointer > 0 else {
            return false
        }

        // make sure that if we move back one, cache isn't nil
        // aka make sure that we aren't at the very beginning
        guard cache[readPointer - 1] != nil else {
            return false
        }
        // move back one byte
        readPointer -= 1
        return true
    }
    
    func read8() throws -> UInt8 {
        var buffer8 : UInt8 = 0

        // check to see if there is enough room to read one byte
        // ex. cache.count = 8, readPointer = 7. readPointer is on last element, and can be read
        guard cache.count - readPointer >= 1 else {
            throw BackwardReadableStreamError.notEnoughBytesToRead
        }
  
        // now we are certain there are enough bytes to read
        buffer8 = cache[readPointer]!; readPointer += 1
        
        updateCache()
        return buffer8
    }
    
    func read16 () throws -> UInt16 {
        var buffer8 : UInt8 = 0
        var buffer16 : UInt16 = 0

        // check to see if there is enough room to read two bytes
        // ex. cache.count = 8, readPointer = 6 is valid
        guard cache.count - readPointer >= 2 else {
            throw BackwardReadableStreamError.notEnoughBytesToRead
            
        }

        // read one byte
        buffer8 = cache[readPointer]!; readPointer += 1
        buffer16 = (UInt16(buffer8) << 8)
        
        // read second byte
        buffer8 = cache[readPointer]!; readPointer += 1
        buffer16 |= UInt16(buffer8)
        
        updateCache()
        return buffer16
    }
    func read32 () throws -> UInt32 {
        var buffer8 : UInt8 = 0
        var buffer32: UInt32 = 0

        // check to see if there is enough room to read four bytes
        // ex. cache.count = 8, readPointer = 4 is valid
        guard cache.count - readPointer >= 4 else {
            throw BackwardReadableStreamError.notEnoughBytesToRead
        }

        buffer8 = cache[readPointer]!; readPointer += 1
        buffer32 = (UInt32(buffer8) << 24)
        
        buffer8 = cache[readPointer]!; readPointer += 1
        buffer32 |= (UInt32(buffer8) << 16)
        
        buffer8 = cache[readPointer]!; readPointer += 1
        buffer32 |= (UInt32(buffer8) << 8)
        
        buffer8 = cache[readPointer]!; readPointer += 1
        buffer32 |= UInt32(buffer8)
        
        updateCache()
        return buffer32
    }
    
    func hasBytesAvailable () -> Bool {
        if cache.count - readPointer > 0 {
            return true
        } else {
            return false
        }
    }
}
