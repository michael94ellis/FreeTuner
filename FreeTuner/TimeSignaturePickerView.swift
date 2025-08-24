//
//  TimeSignaturePickerView.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

struct TimeSignaturePickerView: View {
    @ObservedObject var metronome: Metronome
    @Environment(\.dismiss) private var dismiss
    
    let timeSignatures = Metronome.TimeSignature.allValues
    
    var body: some View {
        NavigationView {
            List {
                ForEach(timeSignatures, id: \.name) { signature in
                    Button(action: {
                        metronome.setTimeSignature(signature)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(signature.beats)/\(signature.noteValue)")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                if signature.name != "\(signature.beats)/\(signature.noteValue)" {
                                    Text(signature.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if metronome.timeSignature.beats == signature.beats &&
                                metronome.timeSignature.noteValue == signature.noteValue {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Time Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MetronomeView(metronome: Metronome())
        .padding()
}
