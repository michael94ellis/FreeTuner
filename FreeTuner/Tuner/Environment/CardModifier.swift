//
//  CardModifier.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

// MARK: - Card Modifiers

/// A view modifier that applies a card-like appearance with rounded corners, background, shadow, and border
struct CardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let padding: EdgeInsets
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    
    init(
        cornerRadius: CGFloat = 16,
        padding: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.05
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color(.sRGBLinear, white: 0, opacity: shadowOpacity),
                        radius: shadowRadius,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
    }
}

/// A view modifier for smaller cards with less padding and smaller corner radius
struct SmallCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    
    init(
        cornerRadius: CGFloat = 12,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.05
    ) {
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color(.sRGBLinear, white: 0, opacity: shadowOpacity),
                        radius: shadowRadius,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
    }
}

/// A view modifier for error/warning cards with colored backgrounds
struct AlertCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let borderColor: Color
    let padding: EdgeInsets
    
    init(
        cornerRadius: CGFloat = 12,
        backgroundColor: Color = Color.orange.opacity(0.1),
        borderColor: Color = Color.orange.opacity(0.3),
        padding: EdgeInsets = EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
    ) {
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a standard card appearance with rounded corners, background, shadow, and border
    func cardStyle(
        cornerRadius: CGFloat = 16,
        padding: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.05
    ) -> some View {
        modifier(CardModifier(
            cornerRadius: cornerRadius,
            padding: padding,
            shadowRadius: shadowRadius,
            shadowOpacity: shadowOpacity
        ))
    }
    
    /// Applies a small card appearance with less padding and smaller corner radius
    func smallCardStyle(
        cornerRadius: CGFloat = 12,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.05
    ) -> some View {
        modifier(SmallCardModifier(
            cornerRadius: cornerRadius,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            shadowRadius: shadowRadius,
            shadowOpacity: shadowOpacity
        ))
    }
    
    /// Applies an alert card appearance with colored background and border
    func alertCardStyle(
        cornerRadius: CGFloat = 12,
        backgroundColor: Color = Color.orange.opacity(0.1),
        borderColor: Color = Color.orange.opacity(0.3),
        padding: EdgeInsets = EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
    ) -> some View {
        modifier(AlertCardModifier(
            cornerRadius: cornerRadius,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            padding: padding
        ))
    }
}

// MARK: - Convenience Extensions for Common Use Cases

extension View {
    /// Applies the standard large card style used for Signal Strength and Pitch Graph
    func largeCardStyle() -> some View {
        cardStyle()
    }
    
    /// Applies the standard small card style used for settings toggles and pitch summary
    func standardCardStyle() -> some View {
        smallCardStyle()
    }
    
    /// Applies the error card style used for error messages
    func errorCardStyle() -> some View {
        alertCardStyle()
    }
    
    /// Applies a warning card style with orange colors
    func warningCardStyle() -> some View {
        alertCardStyle(
            backgroundColor: Color.orange.opacity(0.1),
            borderColor: Color.orange.opacity(0.3)
        )
    }
    
    /// Applies a success card style with green colors
    func successCardStyle() -> some View {
        alertCardStyle(
            backgroundColor: Color.green.opacity(0.1),
            borderColor: Color.green.opacity(0.3)
        )
    }
    
    /// Applies an info card style with blue colors
    func infoCardStyle() -> some View {
        alertCardStyle(
            backgroundColor: Color.blue.opacity(0.1),
            borderColor: Color.blue.opacity(0.3)
        )
    }
}
