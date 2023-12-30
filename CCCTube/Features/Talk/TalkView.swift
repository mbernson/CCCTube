//
//  TalkView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import CCCApi
import SwiftUI


struct TalkView: View {
    let talk: Talk
    @State var selectedRecording: Recording?
    @StateObject private var viewModel = TalkViewModel()
    @State private var error: Error?
    @EnvironmentObject var api: ApiService

    var body: some View {
        ScrollView {
        #if os(tvOS)
        HStack(alignment: .top) {
            TalkMainView(talk: talk, viewModel: viewModel)

            TalkMetaView(talk: talk, selectedRecording: $selectedRecording, viewModel: viewModel)
                .frame(maxWidth: 480, maxHeight: .infinity)
        }
        #else
        VStack(spacing: 20) {
            TalkMainView(talk: talk, viewModel: viewModel)

            TalkMetaView(talk: talk, selectedRecording: $selectedRecording, viewModel: viewModel)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarTitleDisplayMode(.inline)
        #endif
        }
        .navigationTitle(talk.title)
        .task(id: talk) {
            guard talk != viewModel.currentTalk else { return }
            do {
                try await viewModel.loadRecordings(for: talk, from: api)
            } catch {
                self.error = error
            }
        }
        .alert("Failed to load data from the media.ccc.de API", error: $error)
    }
}

private struct TVPlayerView: View {
    let talk: Talk
    let recording: Recording?
    @State private var selectedRecording: Recording?

    var body: some View {
        Button {
            selectedRecording = recording
        } label: {
            TalkThumbnail(talk: talk)
                .overlay {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 20)
                }
        }
        .disabled(recording == nil)
        .fullScreenCover(item: $selectedRecording) { recording in
            TalkPlayerView(talk: talk, recording: recording, automaticallyStartsPlayback: true)
        }
    }
}

private struct TalkMainView: View {
    let talk: Talk
    @ObservedObject var viewModel: TalkViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
            #if os(tvOS)
                TVPlayerView(talk: talk, recording: viewModel.preferredRecording)
            #else
                Group {
                    if let preferredRecording = viewModel.preferredRecording {
                        TalkPlayerView(talk: talk, recording: preferredRecording, automaticallyStartsPlayback: true)
                    } else {
                        Rectangle()
                            .fill(.black)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(16 / 9, contentMode: .fit)
            #endif
            }
            .frame(maxWidth: 1024)
            .frame(maxWidth: .infinity, alignment: .center)

            if let description = talk.description {
                TalkDescriptionView(talk: talk, description: description)
                    .font(.body)
                    .padding(.horizontal)
            }

            CopyrightView(talk: talk, viewModel: viewModel)
                .padding(.horizontal)
        }
        .animation(.default, value: viewModel.copyright)
        #if os(tvOS)
        .focusSection()
        .buttonStyle(.card)
        #endif
        .multilineTextAlignment(.leading)
        #if !os(tvOS)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: talk.frontendLink)
            }
        }
        #endif
    }
}

private struct CopyrightView: View {
    let talk: Talk
    @ObservedObject var viewModel: TalkViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Copyright")
                .font(.headline)

            switch viewModel.copyright {
            case .loading:
                ProgressView()
            case let .copyright(string):
                Text(string)
            case .unknown:
                if let link = talk.link {
                    Text("No copyright information encoded in video. Please refer to the schedule of the organizer of \(talk.conferenceTitle) at: \(link)")
                } else {
                    Text("No copyright information encoded in video. Please refer to the website of the organizer of \(talk.conferenceTitle) at: \(talk.conferenceURL)")
                }
            }
        }
        .font(.caption)
    }
}

private struct TalkDescriptionView: View {
    let talk: Talk
    let description: String

    @State private var talkDescription: TalkDescription?

    private struct TalkDescription: Identifiable {
        let id: Int = 1
        let text: String
    }

    var body: some View {
        let paragraphs = description.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if let shortDescription = paragraphs.first, paragraphs.count > 1 {
            VStack(alignment: .leading, spacing: 20) {
                #if os(tvOS)
                Button {
                    presentTalkDescription()
                } label: {
                    Text(shortDescription)
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)
                        .padding()
                }
                .padding()
                #else
                Text(shortDescription)
                    .lineLimit(5)
                    .multilineTextAlignment(.leading)

                Button("Read more") {
                    presentTalkDescription()
                }
                #endif
            }
            .sheet(item: $talkDescription) { talkDescription in
                NavigationStack {
                    ScrollView {
                        Text(talkDescription.text)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding()
                    }
                    .navigationTitle("Talk description")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done", role: .cancel) {
                                self.talkDescription = nil
                            }
                        }
                    }
                }
            }
        } else {
            Text(description)
                .multilineTextAlignment(.leading)
        }
    }

    func presentTalkDescription() {
        talkDescription = TalkDescription(text: description)
    }
}

private let minutesFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = .minute
    return formatter
}()

private struct TalkMetaView: View {
    let talk: Talk
    @Binding var selectedRecording: Recording?
    @ObservedObject var viewModel: TalkViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label {
                let minutes = minutesFormatter.string(from: talk.duration) ?? "0"
                if talk.duration == 1 {
                    Text("\(minutes) minute")
                } else {
                    Text("\(minutes) minutes")
                }
            } icon: {
                Image(systemName: "clock")
            }

            Label {
                Text(talk.releaseDate, style: .date)
            } icon: {
                Image(systemName: "calendar")
            }

            Label("\(talk.viewCount) views", systemImage: "eye")

            if !talk.persons.isEmpty {
                Label(talk.persons.joined(separator: ", "), systemImage: "person")
            }
        }
    }
}

struct TalkView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TalkView(talk: .example)
                .environmentObject(ApiService())
        }
    }
}
