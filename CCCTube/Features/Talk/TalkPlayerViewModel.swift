//
//  TalkPlayerViewModel.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import AVKit
import CCCApi
import Foundation
import os.log

@Observable
@MainActor
final class TalkPlayerViewModel {
    var player: AVPlayer?

    var currentRecording: Recording?

    private let factory = TalkMetadataFactory()
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!, category: "TalkPlayerViewModel")

    func prepareForPlayback(recording: Recording, talk: Talk) async {
        let item = AVPlayerItem(url: recording.recordingURL)
        item.externalMetadata = factory.createMetadataItems(for: recording, talk: talk)

        let player = AVPlayer(playerItem: item)
        self.player = player
        self.currentRecording = recording
        logger.info(
            "Preparing playback of recording: \(recording.recordingURL.absoluteString, privacy: .public)"
        )

        if let imageURL = talk.posterURL ?? talk.thumbURL,
            let posterImageData = try? await factory.fetchImageData(forURL: imageURL),
            let posterImageMetadata = factory.createArtworkMetadataItem(imageData: posterImageData)
        {
            item.externalMetadata.append(posterImageMetadata)
        }
    }

    func preroll() async {
        guard let player else { return }
        await withCheckedContinuation { continuation in
            _ = player.observe(\.status, options: [.initial, .new]) { player, change in
                if player.status == .readyToPlay {
                    continuation.resume(returning: ())
                }
            }
        }
        if await player.preroll(atRate: 1.0) {
            logger.debug("Preroll success")
        } else {
            logger.warning("Preroll failed")
        }
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }
}
