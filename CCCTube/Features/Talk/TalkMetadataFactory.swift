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

    func createArtworkMetadataItem(forURL url: URL) async throws -> AVMetadataItem? {
        let imageData = try await fetchImagePngData(forURL: url)
        guard let imageData else { return nil }
        let thumbnailMetadata = AVMutableMetadataItem()
        thumbnailMetadata.identifier = .commonIdentifierArtwork
        thumbnailMetadata.dataType = kCMMetadataBaseDataType_PNG as String
        thumbnailMetadata.value = imageData as NSData
        // Specify "und" to indicate an undefined language.
        thumbnailMetadata.extendedLanguageTag = "und" as String
        return thumbnailMetadata.copy() as? AVMetadataItem
    }

    private func fetchImagePngData(forURL url: URL) async throws -> Data? {
        let (imageData, _) = try await URLSession.shared.data(from: url)
        let image = UIImage(data: imageData)
        return image?.pngData()
    }
}
