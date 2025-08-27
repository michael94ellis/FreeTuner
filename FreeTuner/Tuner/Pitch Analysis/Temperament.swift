//
//  Temperament.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import Foundation

enum Temperament: String, CaseIterable {
    case equal = "Equal Temperament"
    case just = "Just Intonation"
    case pythagorean = "Pythagorean Tuning"
    case meantone = "Meantone Temperament"
    case well = "Well Temperament"
    case kirnberger = "Kirnberger III"
    case werckmeister = "Werckmeister III"
    case young = "Young Temperament"
    case quarterComma = "Quarter-Comma Meantone"
    
    var description: String {
        switch self {
        case .equal:
            return "Standard modern tuning. Each semitone is exactly 100 cents."
        case .just:
            return "Pure intervals based on simple frequency ratios. More harmonious but limited to certain keys."
        case .pythagorean:
            return "Based on perfect fifths (3:2 ratio). Bright, pure fifths but problematic thirds."
        case .meantone:
            return "Historical temperament that tempers fifths to improve thirds. Good for Renaissance music."
        case .well:
            return "Compromise tuning that works well in all keys. Bach's preferred temperament."
        case .kirnberger:
            return "Johann Kirnberger's temperament. Pure thirds in C, F, G major. Good for Bach's music."
        case .werckmeister:
            return "Andreas Werckmeister's temperament. Well-balanced for all keys. Popular in Baroque period."
        case .young:
            return "Thomas Young's temperament. Excellent for Classical and early Romantic music."
        case .quarterComma:
            return "Quarter-comma meantone. Pure major thirds, tempered fifths. Renaissance standard."
        }
    }
}
