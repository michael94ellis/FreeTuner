//
//  DeviationNoteView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct DeviationNoteView: View {
    @Environment(\.isPad) private var isPad
    let note: String
    let deviation: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(note)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("\(deviation)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(deviation == 0 ? .green : .orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(deviationBackground)
        }
    }
    
    private var deviationBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(deviation == 0 ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
    }
}

#Preview {
    HStack(spacing: 12) {
        DeviationNoteView(note: "C", deviation: 0)
        DeviationNoteView(note: "D", deviation: 4)
        DeviationNoteView(note: "E", deviation: -2)
        DeviationNoteView(note: "F", deviation: 8)
    }
    .padding()
    .background(Color(.systemBackground))
}
