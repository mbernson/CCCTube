//
//  TalkView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import CCCApi
import SwiftUI

enum CopyrightState: Equatable {
    case loading
    case copyright(String)
    case unknown
}

@MainActor class TalkViewModel: ObservableObject {
    @Published var hdRecording: Recording?
    @Published var sdRecording: Recording?
    @Published var audioRecording: Recording?
    @Published var copyright: CopyrightState = .loading

    private let mediaAnalyzer = MediaAnalyzer()

    func loadRecordings(for talk: Talk, from api: CCCApi.ApiService) async throws {
        let recordings = try await api.recordings(for: talk)
        hdRecording = recordings.first(where: { $0.isHighQuality })
        sdRecording = recordings.first(where: { !$0.isHighQuality && $0.isVideo })
        audioRecording = recordings.first(where: { $0.isAudio })

        for recording in recordings {
            if copyright == .loading {
                let copyrightString = try? await mediaAnalyzer.copyrightMetadata(for: recording)
                if let copyrightString {
                    copyright = .copyright(copyrightString)
                }
            }
        }
        if copyright == .loading {
            copyright = .unknown
        }
    }
}

struct TalkView: View {
    let talk: Talk

    @State var selectedRecording: Recording?
    @State private var talkDescription: TalkDescription?
    @StateObject private var viewModel = TalkViewModel()

    @State private var error: Error?

    @EnvironmentObject var api: ApiService

    static let minutesFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .minute
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                if let thumbURL = talk.thumbURL {
                    AsyncImage(url: thumbURL) { image in
                        image.resizable().scaledToFit()
                            .cornerRadius(8)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: 480)
                }

                if let description = talk.description {
                    if let descriptionParts = talk.description?.components(separatedBy: "\n\n")
                        .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }),
                        let shortDescription = descriptionParts.first, descriptionParts.count > 1
                    {
                        Button {
                            talkDescription = TalkDescription(text: description)
                        } label: {
                            Text("\(shortDescription)... **MORE**")
                                .lineLimit(5)
                                .padding(10)
                        }
                        .buttonBorderShape(.roundedRectangle)
                        #if os(tvOS)
                            .buttonStyle(.card)
                        #endif
                            .font(.body)
                            .sheet(item: $talkDescription) { talkDescription in
                                Text(talkDescription.text)
                                    .font(.body)
                            }
                    } else {
                        Text(description)
                            .font(.body)
                    }
                }

                Text("Copyright")
                    .font(.headline)

                Group {
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
                }.font(.caption)
            }
            .animation(.default, value: viewModel.copyright)
            #if os(tvOS)
                .focusSection()
            #endif
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 20) {
                Group {
                    let videoRecording = viewModel.hdRecording ?? viewModel.sdRecording
                    if videoRecording != nil {
                        Button {
                            self.selectedRecording = videoRecording
                        } label: {
                            Label("Play", systemImage: "play")
                                .frame(maxWidth: .infinity)
                        }
                    }

                    let audioRecording = viewModel.audioRecording
                    if let audioRecording {
                        Button {
                            self.selectedRecording = audioRecording
                        } label: {
                            Label("Play audio", systemImage: "play")
                                .frame(maxWidth: .infinity)
                        }
                    }

                    if videoRecording == nil && audioRecording == nil {
                        Text("No recording available")
                    }
                }

                Label {
                    let minutes = Self.minutesFormatter.string(from: talk.duration) ?? "0"
                    Text("\(minutes) minutes")
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
            #if os(tvOS)
            .focusSection()
            #endif
            .frame(maxWidth: 480, maxHeight: .infinity)
        }
        .navigationTitle(Text(talk.title))
        .task {
            do {
                try await viewModel.loadRecordings(for: talk, from: api)
            } catch {
                self.error = error
            }
        }
        .fullScreenCover(item: $selectedRecording) { recording in
            TalkPlayerView(talk: talk, recording: recording)
        }
        .alert("Failed to load data from the media.cc.de API", error: $error)
    }
}

private struct TalkDescription: Identifiable {
    let id: Int = 1
    let text: String
}

struct TalkView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TalkView(talk: .example)
                .environmentObject(ApiService())
        }
    }
}
