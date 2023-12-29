//
//  Alert+Error.swift
//  CCCTube
//
//  Created by Mathijs Bernson on 29/12/2023.
//

import Foundation
import SwiftUI

extension View {
    /// Presents an alert when an error is present.
    func alert<E: Error>(_ titleKey: LocalizedStringKey, error: Binding<E?>, buttonTitleKey: LocalizedStringKey = "Ok") -> some View {
        modifier(ErrorAlert(error: error, titleKey: titleKey, buttonTitleKey: buttonTitleKey))
    }
}

/// A modifier that presents an alert when an error is present.
private struct ErrorAlert<E: Error>: ViewModifier {
    @Binding var error: E?
    let titleKey: LocalizedStringKey
    let buttonTitleKey: LocalizedStringKey

    var isPresented: Bool {
        error != nil
    }

    func body(content: Content) -> some View {
        content.alert(titleKey, isPresented: .constant(isPresented)) {
            Button(buttonTitleKey, action: dismiss)
        } message: {
            if let message = error?.localizedDescription {
                Text(message)
            }
        }
    }

    func dismiss() {
        error = nil
    }
}

#Preview("Error alert") {
    Text(verbatim: "Preview text")
        .alert("Preview error title", error: .constant(CCCTubeError(message: "Failed to load all the things")))
}
