//
//  TimeSignature.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/26/25.
//

struct TimeSignature: Equatable {
    let beats: Int
    let noteValue: Int
    let name: String
    
    static let twoTwo = TimeSignature(beats: 2, noteValue: 2, name: "2/2 (Cut Time)")
    static let twoFour = TimeSignature(beats: 2, noteValue: 4, name: "2/4")
    static let threeFour = TimeSignature(beats: 3, noteValue: 4, name: "3/4")
    static let fourFour = TimeSignature(beats: 4, noteValue: 4, name: "4/4 (Common Time)")
    static let fiveFour = TimeSignature(beats: 5, noteValue: 4, name: "5/4")
    static let sixFour = TimeSignature(beats: 6, noteValue: 4, name: "6/4")
    static let threeEight = TimeSignature(beats: 3, noteValue: 8, name: "3/8")
    static let sixEight = TimeSignature(beats: 6, noteValue: 8, name: "6/8")
    static let nineEight = TimeSignature(beats: 9, noteValue: 8, name: "9/8")
    static let twelveEight = TimeSignature(beats: 12, noteValue: 8, name: "12/8")
    
    static var allValues: [TimeSignature] = [.twoTwo,
                                             .twoFour,
                                             .threeFour,
                                             .fourFour,
                                             .fiveFour,
                                             .sixFour,
                                             .threeEight,
                                             .sixEight,
                                             .nineEight,
                                             .twelveEight]
}
