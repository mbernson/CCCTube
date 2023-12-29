//
//  MediaAnalyzer.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 01/08/2022.
//

import AVFoundation
import CCCApi
import Foundation

struct MediaAnalyzer {
    func copyrightMetadata(for recording: Recording) async throws -> String? {
        let asset = AVAsset(url: recording.recordingURL)
        let metadata = try await asset.load(.metadata)
        for meta in metadata {
            if meta.identifier == .commonIdentifierCopyrights || meta.identifier == .id3MetadataCopyright || meta.identifier == .iTunesMetadataCopyright {
                return try await meta.load(.stringValue)
            }
        }
        return nil
    }
}
