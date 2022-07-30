//
//  TalkPlayerView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import SwiftUI
import AVKit
import CCCApi

struct TalkPlayerView: View {
  let talk: Talk
  let player: AVPlayer
  let recording: Recording

  init(talk: Talk, recording: Recording) {
    let factory = TalkMetadataFactory()
    self.talk = talk
    self.recording = recording
    let item = AVPlayerItem(url: recording.recordingURL)
    item.externalMetadata = factory.createMetadataItems(for: recording, talk: talk)
    player = AVPlayer(playerItem: item)
  }

  var body: some View {
    VideoPlayer(player: player)
      .ignoresSafeArea()
      .onAppear {
        player.play()
        print("Starting playback of: \(recording.recordingURL.absoluteString)")
      }
  }
}

struct TalkMetadataFactory {
  func createMetadataItems(for recording: Recording, talk: Talk) -> [AVMetadataItem] {
    var mapping: [AVMetadataIdentifier: Any] = [
      .commonIdentifierTitle: talk.title,
      .commonIdentifierCreationDate: talk.releaseDate,
      .commonIdentifierLanguage: recording.language,
    ]

    do {
      if let posterURL = talk.posterURL {
        mapping[.commonIdentifierArtwork] = UIImage(data: try Data(contentsOf: posterURL))?.pngData() as Any
      }
    } catch {
      // Ignore error
    }

    if let subtitle = talk.subtitle {
      mapping[.iTunesMetadataTrackSubTitle] = subtitle
    }

    if let description = talk.description {
      mapping[.commonIdentifierDescription] = description
    }

    if !talk.persons.isEmpty {
      mapping[.commonIdentifierArtist] = talk.persons.joined(separator: ", ")
    }

    return mapping.compactMap { id, value in
      createMetadataItem(for: id, value: value, language: talk.originalLanguage)
    }
  }

  private func createMetadataItem(for identifier: AVMetadataIdentifier, value: Any, language: String?) -> AVMetadataItem {
    let item = AVMutableMetadataItem()
    item.identifier = identifier
    item.value = value as? NSCopying & NSObjectProtocol
    // Specify "und" to indicate an undefined language.
    item.extendedLanguageTag = "und"
    return item.copy() as! AVMetadataItem
  }
}
