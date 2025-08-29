//
//  FontHelperKey.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/29/25.
//

import SwiftUI

private struct FontHelperKey: EnvironmentKey {
    static let defaultValue: FontHelper = FontHelper()
}

extension EnvironmentValues {
    var fontHelper: FontHelper {
        get { self[FontHelperKey.self] }
        set { self[FontHelperKey.self] = newValue }
    }
}
