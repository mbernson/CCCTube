//
//  VideoPlayerView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 01/07/2023.
//

import SwiftUI
import AVKit

/// A view that wraps `AVPlayerViewController`
/// It is needed in order to support picture-in-picture.
struct VideoPlayerView: UIViewControllerRepresentable {
  let player: AVPlayer?

  func makeUIViewController(context: Context) -> AVPlayerViewController {
    let playerViewController = AVPlayerViewController()
    #if os(tvOS)
      playerViewController.appliesPreferredDisplayCriteriaAutomatically = true
      playerViewController.transportBarIncludesTitleView = true
    #endif
    return playerViewController
  }

  func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
    playerViewController.player = player
  }
}