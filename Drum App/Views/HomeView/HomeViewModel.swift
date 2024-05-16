//
//  HomeViewModel.swift
//  Drum App
//
//  Created by Oliver Li on 5/16/24.
//

import SwiftUI

final class HomeViewModel: ObservableObject {
    @Binding var currentView: AppView
    @Binding var documentURL: URL?

    init(currentView: Binding<AppView>, documentURL: Binding<URL?>) {
        self._currentView = currentView
        self._documentURL = documentURL
    }

    func presentUploadFileView() {
        let uploadFile = Upload_File(documentURL: $documentURL, currentView: $currentView)
        let controller = UIHostingController(rootView: uploadFile)
        controller.modalPresentationStyle = .formSheet
        UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true)
    }
}
