//
//  UserDefaultsManager.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import Foundation

@Observable
class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let showPitchGraph = "showPitchGraph"
        static let showSignalStrength = "showSignalStrength"
        static let showReferenceLabels = "showReferenceLabels"
    }
    
    // MARK: - Properties
    var showPitchGraph: Bool {
        get {
            defaults.object(forKey: Keys.showPitchGraph) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: Keys.showPitchGraph)
        }
    }
    
    var showSignalStrength: Bool {
        get {
            defaults.object(forKey: Keys.showSignalStrength) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: Keys.showSignalStrength)
        }
    }
    
    var showReferenceLabels: Bool {
        get {
            defaults.object(forKey: Keys.showReferenceLabels) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: Keys.showReferenceLabels)
        }
    }
    
    private init() {}
}
