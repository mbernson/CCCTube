//
//  CCCTubeApp.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import SwiftUI
import AVKit

@main
struct CCCTubeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                    } catch {
                    }
                }
        }
    }
}
