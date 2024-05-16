import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    var title: Text
    var message: Text
    var dismissButton: Alert.Button
}

struct AlertContext {
    static let invalidData = AlertItem(title: Text("Invalid Data"),
                                       message: Text("The data received from the server was invalid."),
                                       dismissButton: .default(Text("OK")))
    
    static let invalidURL = AlertItem(title: Text("Invalid URL"),
                                      message: Text("There was an issue connecting to the server."),
                                      dismissButton: .default(Text("OK")))
    
    static let invalidResponse = AlertItem(title: Text("Invalid Response"),
                                           message: Text("Invalid response from the server."),
                                           dismissButton: .default(Text("OK")))
    
    static let unableToComplete = AlertItem(title: Text("Unable to Complete"),
                                            message: Text("Unable to complete your request at this time. Please check your internet connection."),
                                            dismissButton: .default(Text("OK")))
    
    static let processingError = AlertItem(title: Text("Processing Error"),
                                           message: Text("There was an error processing the MIDI file."),
                                           dismissButton: .default(Text("OK")))
}
