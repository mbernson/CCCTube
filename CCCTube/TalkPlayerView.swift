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
    var mapping: [AVMetadataIdentifier: AVMetadataValue] = [
      .commonIdentifierTitle: talk.title as NSString,
      .commonIdentifierCreationDate: talk.releaseDate as NSDate,
      .commonIdentifierLanguage: recording.language as NSString,
    ]

    do {
      if let posterURL = talk.posterURL {
        // TODO: Fix synchronous loading of the poster image to be async
        mapping[.commonIdentifierArtwork] = UIImage(data: try Data(contentsOf: posterURL))?.pngData() as? NSData
      }
    } catch {
      // Ignore error
    }

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
      createMetadataItem(for: id, value: value, language: talk.originalLanguage)
    }
  }

  /// Specifying "und" indicates an undefined language.
  private let undefinedLanguageTag = "und"

  typealias AVMetadataValue = NSCopying & NSObjectProtocol

  private func createMetadataItem(for identifier: AVMetadataIdentifier, value: AVMetadataValue, language: String?) -> AVMetadataItem {
    let item = AVMutableMetadataItem()
    item.identifier = identifier
    item.value = value
    item.extendedLanguageTag = language ?? undefinedLanguageTag
    return item.copy() as! AVMetadataItem
  }
}
