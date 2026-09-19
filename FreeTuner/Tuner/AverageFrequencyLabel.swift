import SwiftUI

struct AverageFrequencyLabel: View {
    
    let pitchData: [PitchDataPoint]
    @Environment(\.isPad) private var isPad
    
    var averageFrequency: Float {
        guard !pitchData.isEmpty else { return 0 }
        let sum = pitchData.reduce(0) { $0 + $1.frequency }
        return sum / Float(pitchData.count)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Average frequency
            VStack(spacing: isPad ? 6 : 4) {
                Text("Average")
                    .font(isPad ? .title3 : .subheadline)
                    .foregroundColor(.textSecondary)
                    .frame(minWidth: 80, alignment: .trailing)
                Text("\(Int(averageFrequency)) Hz")
                    .font(isPad ? .title3 : .subheadline)
                    .foregroundColor(.text)
                    .frame(minWidth: 80, alignment: .trailing)
                    .accessibilityLabel("Average frequency")
                    .accessibilityValue("\(Int(averageFrequency)) Hertz")
                    .accessibilityHint("Average frequency over the recorded time period")
                    .accessibilityAddTraits(.updatesFrequently)
            }
            .padding(.vertical, isPad ? 16 : 8)
            .padding(.horizontal, isPad ? 12 : 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.backgroundElevated.opacity(0.5))
            )
            .frame(maxWidth: .infinity)
        }
    }
}
