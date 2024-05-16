//
//  HomeView.swift
//  Drum App
//
//  Created by Oliver Li on 8/12/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel: HomeViewModel

    init(currentView: Binding<AppView>, documentURL: Binding<URL?>) {
        self.viewModel = HomeViewModel(currentView: currentView, documentURL: documentURL)
    }

    var body: some View {
        ZStack(alignment: .center) {
            backgroundImage
            content
        }
    }

    private var backgroundImage: some View {
        Image("backdrop")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
    }

    private var content: some View {
        VStack(spacing: 10) {
            titleImage
            uploadButton
        }
    }

    private var titleImage: some View {
        Image("title")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 60)
            .padding(.horizontal)
    }

    private var uploadButton: some View {
        Button(action: viewModel.presentUploadFileView) {
            HStack {
                Image("uploadbutton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 36)
            }
        }
    }
}
