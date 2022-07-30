//
//  ConferenceView.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import SwiftUI

struct ConferenceView: View {
  let conference: Conference
  var body: some View {
    Text(conference.title)
  }
}

struct ConferenceView_Previews: PreviewProvider {
  static var previews: some View {
    ConferenceView(conference: .example)
  }
}
