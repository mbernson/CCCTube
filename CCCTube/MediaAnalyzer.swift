//
//  MediaAnalyzer.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 01/08/2022.
//

import Foundation
import AVFoundation
import CCCApi

struct MediaAnalyzer {
  func copyrightMetadata(for recording: Recording) async -> String? {
    let asset = AVAsset(url: recording.recordingURL)
    let formatsKey = "availableMetadataFormats"
    _ = await asset.loadValues(forKeys: [formatsKey])
    var error: NSError? = nil
    let status = asset.statusOfValue(forKey: formatsKey, error: &error)
    if status == .loaded {
      for format in asset.availableMetadataFormats {
        let metadata = asset.metadata(forFormat: format)
        // process format-specific metadata collection
        print(metadata)
        for meta in metadata {
          if meta.identifier == .commonIdentifierCopyrights || meta.identifier == .id3MetadataCopyright || meta.identifier == .iTunesMetadataCopyright {
            return meta.stringValue
          }
        }
      }
    }
    return nil
  }
}
