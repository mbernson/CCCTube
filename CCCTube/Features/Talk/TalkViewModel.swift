//
//  TalkViewModel.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import Foundation
import AVKit
import CCCApi

enum CopyrightState: Equatable {
    case loading
    case copyright(String)
    case unknown
}

@MainActor class TalkViewModel: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var preferredRecording: Recording?
    @Published var copyright: CopyrightState = .loading

    private let mediaAnalyzer = MediaAnalyzer()

    func loadRecordings(for talk: Talk, from api: CCCApi.ApiService) async throws {
        let recordings = try await api.recordings(for: talk)
        self.recordings = recordings
        let hdRecording = recordings.first(where: { $0.isHighQuality && $0.isVideo })
        let sdRecording = recordings.first(where: { !$0.isHighQuality && $0.isVideo })
        let audioRecording = recordings.first(where: { $0.isAudio })
        self.preferredRecording = hdRecording ?? sdRecording ?? audioRecording

        await loadCopyright(for: recordings)
    }

    private func loadCopyright(for recordings: [Recording]) async {
        for recording in recordings {
            if copyright == .loading {
                let copyrightString = try? await mediaAnalyzer.copyrightMetadata(for: recording)
                if let copyrightString {
                    copyright = .copyright(copyrightString)
                }
            }
        }
        if copyright == .loading {
            copyright = .unknown
        }
    }
}
