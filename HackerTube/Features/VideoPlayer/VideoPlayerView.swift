//
//  VideoPlayerView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 01/07/2023.
//

import AVKit
import SwiftUI
import os.log

struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer?

    func makeUIViewController(context: Context) -> VideoPlayerViewController {
        let playerViewController = VideoPlayerViewController()
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

    func updateUIViewController(_ playerViewController: VideoPlayerViewController, context: Context)
    {
        playerViewController.player = player
    }

    func makeCoordinator() -> VideoPlayerCoordinator {
        VideoPlayerCoordinator()
    }

    static func dismantleUIViewController(
        _ playerViewController: VideoPlayerViewController, coordinator: Coordinator
    ) {
        playerViewController.player?.cancelPendingPrerolls()
        playerViewController.player?.pause()
    }
}

class VideoPlayerCoordinator: NSObject, AVPlayerViewControllerDelegate {
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!, category: "VideoPlayerCoordinator")

    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        logger.error("Failed to start picture in picture: \(error)")
    }
}

class VideoPlayerViewController: AVPlayerViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        UIApplication.shared.isIdleTimerDisabled = false
    }
}
