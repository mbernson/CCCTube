//
//  TalkMetadataFactory.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import Foundation
import AVKit
import CCCApi

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
