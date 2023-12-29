//
//  TalkPlayerView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import SwiftUI
import CCCApi

struct TalkPlayerView: View {
    let talk: Talk
    let recording: Recording

    @StateObject private var viewModel = TalkPlayerViewModel()

    var body: some View {
        VideoPlayerView(player: viewModel.player)
            .ignoresSafeArea()
            .task {
                await viewModel.play(recording: recording, ofTalk: talk)
            }
    }
}

#Preview {
    TalkPlayerView(talk: .example, recording: .example)
}
