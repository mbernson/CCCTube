//
//  VideoPlayerView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 01/07/2023.
//

import AVKit
import os.log
import SwiftUI

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()

        playerViewController.modalPresentationStyle = .fullScreen

        playerViewController.allowsPictureInPicturePlayback = true
        #if os(tvOS)
            playerViewController.appliesPreferredDisplayCriteriaAutomatically = true
            playerViewController.transportBarIncludesTitleView = true
        #else
            playerViewController.canStartPictureInPictureAutomaticallyFromInline = true
        #endif

        return playerViewController
    }

    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        playerViewController.player = player
        playerViewController.delegate = context.coordinator
    }

    func makeCoordinator() -> VideoPlayerCoordinator {
        VideoPlayerCoordinator()
    }

    static func dismantleUIViewController(_ playerViewController: AVPlayerViewController, coordinator: Coordinator) {
        playerViewController.player?.cancelPendingPrerolls()
        playerViewController.player?.pause()
        playerViewController.player = nil
    }
}

class VideoPlayerCoordinator: NSObject, AVPlayerViewControllerDelegate {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VideoPlayerCoordinator")

    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        logger.error("Failed to start picture in picture: \(error)")
    }
}
