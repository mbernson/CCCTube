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

@MainActor class TalkPlayerViewModel: ObservableObject {
    var player: AVPlayer?

    private let factory = TalkMetadataFactory()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TalkPlayerViewModel")

    func play(recording: Recording, ofTalk talk: Talk) async {
        let item = AVPlayerItem(url: recording.recordingURL)
        item.externalMetadata = factory.createMetadataItems(for: recording, talk: talk)
        let player = AVPlayer(playerItem: item)
        self.player = player
        objectWillChange.send()
        player.play()
        logger.info("Starting playback of recording: \(recording.recordingURL.absoluteString, privacy: .public)")

        // Fetch poster image and append it to the metadata
        if let imageMetadata = await fetchPosterImage(for: talk) {
            item.externalMetadata.append(imageMetadata)
        }
    }

    private func fetchPosterImage(for talk: Talk) async -> AVMetadataItem? {
        do {
            if let posterURL = talk.posterURL, let imageData = try await factory.fetchImageData(forPosterImageURL: posterURL) {
                let imageMetadata = factory.createMetadataItem(for: .commonIdentifierArtwork, value: imageData as NSData, language: nil)
                return imageMetadata
            } else {
                return nil
            }
        } catch {
            logger.error("Failed to fetch poster image for talk at URL \(talk.posterURL?.absoluteString ?? "(nil)")")
            return nil
        }
    }
}
