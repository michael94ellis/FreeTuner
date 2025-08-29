//
//  IsPadKey.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

private struct IsPadKey: EnvironmentKey {
    static let defaultValue: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

extension EnvironmentValues {
    var isPad: Bool {
        get { self[IsPadKey.self] }
        set { self[IsPadKey.self] = newValue }
    }
}
