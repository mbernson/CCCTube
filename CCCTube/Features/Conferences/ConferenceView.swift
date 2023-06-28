//
//  ConferenceView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import SwiftUI
import CCCApi

struct ConferenceView: View {
  let conference: Conference

  @State var error: NetworkError? = nil
  @State var isErrorPresented = false

  @EnvironmentObject var api: ApiService

  var body: some View {
    Text(conference.title)
  }
}

struct ConferenceView_Previews: PreviewProvider {
  static var previews: some View {
    ConferenceView(conference: .example)
  }
}
