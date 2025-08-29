//
//  IsPadKey.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

// MARK: - Environment Key
private struct IsPadKey: EnvironmentKey {
    static let defaultValue: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

// MARK: - Environment Values Extension
extension EnvironmentValues {
    var isPad: Bool {
        get { self[IsPadKey.self] }
        set { self[IsPadKey.self] = newValue }
    }
}

// MARK: - View Extension
extension View {
    func isPad(_ isPad: Bool) -> some View {
        environment(\.isPad, isPad)
    }
}
