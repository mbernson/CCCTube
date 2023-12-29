//
//  RelatedTalksViewController.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import SwiftUI
import UIKit
import CCCApi

class RelatedTalksViewController: UIHostingController<RelatedTalksView> {
    let apiService = ApiService()

    init(talk: Talk) {
        super.init(rootView: RelatedTalksView(talk: talk))
        title = String(localized: "Related talks")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct RelatedTalksView: View {
    let talk: Talk
    @EnvironmentObject var api: ApiService
    @State private var related: [Talk] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(related) { talk in
                    Link(destination: URL(string: "ccctube://talk/\(talk.id)")!) {
                        TalkThumbnail(talk: talk)
                    }
                }
            }
            .padding()
        }
        .focusSection()
        .buttonStyle(.card)
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .task(id: talk) {
            isLoading = true
            related = await withTaskGroup(of: Talk?.self, returning: [Talk].self) { group in
                for related in talk.related {
                    group.addTask {
                        try? await api.talk(id: related.eventGUID)
                    }
                }
                var talks: [Talk] = []
                for await talk in group {
                    if let talk {
                        talks.append(talk)
                    }
                }
                return talks
            }
            isLoading = false
        }
    }
}

#Preview("Related talks") {
    RelatedTalksView(talk: .example)
        .environmentObject(ApiService())
        .frame(height: 200)
}
