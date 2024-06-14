//
//  VideoPlayerView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 01/07/2023.
//

import AVKit
import os.log
import SwiftUI

@MainActor
struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer?
    let dismiss: () -> Void

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.delegate = context.coordinator
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
    }

    func makeCoordinator() -> VideoPlayerCoordinator {
        VideoPlayerCoordinator(dismiss: dismiss)
    }

    static func dismantleUIViewController(_ playerViewController: AVPlayerViewController, coordinator: Coordinator) {
        playerViewController.player?.cancelPendingPrerolls()
        playerViewController.player?.pause()
    }
}

class VideoPlayerCoordinator: NSObject, AVPlayerViewControllerDelegate {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VideoPlayerCoordinator")
    let dismiss: () -> Void

    init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
        super.init()
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, failedToStartPictureInPictureWithError error: Error) {
        logger.error("Failed to start picture in picture: \(error)")
    }

    #if !os(tvOS)
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: any UIViewControllerTransitionCoordinator) {
        dismiss()
    }
    #endif
}
