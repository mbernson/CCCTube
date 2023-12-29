//
//  TalkPlayerViewModel.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import Foundation
import AVKit
import CCCApi
import os.log

class TalkPlayerViewModel: ObservableObject {
    var player: AVPlayer?

    private let factory = TalkMetadataFactory()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TalkPlayerViewModel")

    private var statusObservation: NSKeyValueObservation?

    func prepareForPlayback(recording: Recording, talk: Talk) async {
        let item = AVPlayerItem(url: recording.recordingURL)
        item.externalMetadata = factory.createMetadataItems(for: recording, talk: talk)

        let player = AVPlayer(playerItem: item)
        self.player = player
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        logger.info("Preparing playback of recording: \(recording.recordingURL.absoluteString, privacy: .public)")

        // Fetch poster image and append it to the metadata
        if let imageMetadata = await fetchPosterImage(for: talk) {
            item.externalMetadata.append(imageMetadata)
        }
    }

    func preroll() async {
        guard let player else { return }
        await withCheckedContinuation { continuation in
            statusObservation = player.observe(\.status, options: [.initial, .new]) { player, change in
                if player.status == .readyToPlay {
                    continuation.resume(returning: ())
                    self.statusObservation?.invalidate()
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

    private func fetchPosterImage(for talk: Talk) async -> AVMetadataItem? {
        do {
            if let imageURL = talk.posterURL ?? talk.thumbURL {
                return try await factory.createArtworkMetadataItem(forURL: imageURL)
            } else {
                return nil
            }
        } catch {
            logger.error("Failed to fetch poster image for talk at URL \(talk.posterURL?.absoluteString ?? "(nil)")")
            return nil
        }
    }
}
