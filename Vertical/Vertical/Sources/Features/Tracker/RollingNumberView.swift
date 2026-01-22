import SwiftUI

/// Configuration for the rolling number animation
enum RollingNumberConfiguration {
    /// Peak VAM value for color interpolation (typical pro cycling ascent rate)
    static let peakVam: Double = 1200
    /// Minimum digits to display (prevents layout jumps when value shrinks)
    static let minimumDigits: Int = 4
}

struct RollingNumberView: View {
    let value: Int
    let font: Font
    let fontSize: CGFloat
    let minimumDigits: Int
    
    init(value: Int, font: Font = .system(size: 72, weight: .black, design: .rounded), fontSize: CGFloat = 72, minimumDigits: Int = RollingNumberConfiguration.minimumDigits) {
        self.value = value
        self.font = font
        self.fontSize = fontSize
        self.minimumDigits = minimumDigits
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(paddedDigits.indices, id: \.self) { index in
                DigitView(
                    digit: paddedDigits[index],
                    font: font,
                    fontSize: fontSize
                )
            }
        }
    }
    
    /// Pads the value with leading zeros to maintain consistent width
    private var paddedDigits: [Int] {
        let stringValue = String(value)
        let paddingCount = max(0, minimumDigits - stringValue.count)
        let paddedString = String(repeating: "0", count: paddingCount) + stringValue
        return paddedString.compactMap { Int(String($0)) }
    }
}

private struct DigitView: View {
    let digit: Int
    let font: Font
    let fontSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0...9, id: \.self) { num in
                    Text("\(num)")
                        .font(font)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .offset(y: -CGFloat(digit) * geometry.size.height)
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0), value: digit)
        }
        .frame(width: dynamicDigitWidth)
        .clipped() // Prevent overflow from showing adjacent digits
    }
    
    /// Calculate digit width based on font size (approximately 0.6 of font size for rounded numbers)
    private var dynamicDigitWidth: CGFloat {
        return fontSize * 0.6
    }
}

#Preview {
    VStack(spacing: 20) {
        RollingNumberView(value: 0, fontSize: 72)
            .frame(height: 80)
        
        RollingNumberView(value: 1234, fontSize: 72)
            .frame(height: 80)
        
        RollingNumberView(value: 5678, fontSize: 72)
            .frame(height: 80)
            .foregroundColor(.pink)
    }
    .preferredColorScheme(.dark)
}
