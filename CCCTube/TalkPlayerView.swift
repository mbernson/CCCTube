//
//  TalkPlayerView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import AVKit
import CCCApi
import SwiftUI

struct TalkPlayerView: View {
    let talk: Talk
    @State var player: AVPlayer?
    let recording: Recording
    let factory = TalkMetadataFactory()

    var body: some View {
        VideoPlayerView(player: player)
            .ignoresSafeArea()
            .task {
                let item = AVPlayerItem(url: recording.recordingURL)
                item.externalMetadata = factory.createMetadataItems(for: recording, talk: talk)
                do {
                    if let posterURL = talk.posterURL {
                        if let imageData = try await factory.fetchImageData(forPosterImageURL: posterURL) {
                            let imageMetadata = factory.createMetadataItem(for: .commonIdentifierArtwork, value: imageData as NSData, language: nil)
                            item.externalMetadata.append(imageMetadata)
                        }
                    }
                } catch {
                    // Ignore error
                }
                player = AVPlayer(playerItem: item)
                player?.play()
                print("Starting playback of: \(recording.recordingURL.absoluteString)")
            }
    }
}

struct TalkMetadataFactory {
    func createMetadataItems(for recording: Recording, talk: Talk) -> [AVMetadataItem] {
        var mapping: [AVMetadataIdentifier: AVMetadataValue] = [
            .commonIdentifierTitle: talk.title as NSString,
            .commonIdentifierCreationDate: talk.releaseDate as NSDate,
            .commonIdentifierLanguage: recording.language as NSString,
        ]

        if let subtitle = talk.subtitle {
            mapping[.iTunesMetadataTrackSubTitle] = subtitle as NSString
        }

        if let description = talk.description {
            mapping[.commonIdentifierDescription] = description as NSString
        }

        if !talk.persons.isEmpty {
            mapping[.commonIdentifierArtist] = talk.persons.joined(separator: ", ") as NSString
        }

        return mapping.compactMap { id, value in
            createMetadataItem(for: id, value: value, language: recording.language)
        }
    }

    /// Specifying "und" indicates an undefined language.
    private let undefinedLanguageTag = "und"

    typealias AVMetadataValue = NSCopying & NSObjectProtocol

    func createMetadataItem(for identifier: AVMetadataIdentifier, value: AVMetadataValue, language: String?) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value
        item.extendedLanguageTag = language ?? undefinedLanguageTag
        return item.copy() as! AVMetadataItem
    }

    func fetchImageData(forPosterImageURL posterURL: URL) async throws -> Data? {
        let (imageData, _) = try await URLSession.shared.data(from: posterURL)
        let image = UIImage(data: imageData)
        let jpegData = image?.jpegData(compressionQuality: 0.8)
        return jpegData
    }
}
