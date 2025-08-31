//
//  FontHelper.swift
//  FreeTuner
//
//  Created by Michael Ellis on 8/24/25.
//

import SwiftUI

/// Centralized font management system for FreeTuner
/// Provides consistent typography across the app with support for different device sizes
struct FontHelper {
    
    // MARK: - Font Sizes
    
    /// Base font sizes that scale with device type
    struct Size {
        // Large display fonts (main note display, titles) - custom sizes needed
        static let extraLarge = FontSize(phone: 72, pad: 128, weight: .bold)
        static let large = FontSize(phone: 48, pad: 64, weight: .bold)
        static let mediumLarge = FontSize(phone: 32, pad: 48, weight: .semibold)
        
        // Standard text sizes - use dynamic types
        static let title = FontSize(phone: 24, pad: 32, weight: .semibold)
        static let heading = FontSize(phone: 20, pad: 28, weight: .semibold)
        static let subheading = FontSize(phone: 18, pad: 24, weight: .semibold)
        static let body = FontSize(phone: 16, pad: 20, weight: .medium)
        static let caption = FontSize(phone: 14, pad: 18, weight: .medium)
        static let small = FontSize(phone: 12, pad: 16, weight: .medium)
        static let tiny = FontSize(phone: 10, pad: 14, weight: .medium)
        
        // Specialized sizes - custom sizes needed
        static let noteMarker = FontSize(phone: 18, pad: 36, weight: .bold)
        static let frequency = FontSize(phone: 14, pad: 36, weight: .medium)
        static let cents = FontSize(phone: 16, pad: 24, weight: .semibold)
        static let octave = FontSize(phone: 16, pad: 24, weight: .semibold)
        static let label = FontSize(phone: 10, pad: 20, weight: .medium)
        static let icon = FontSize(phone: 48, pad: 64, weight: .light)
        static let iconSmall = FontSize(phone: 24, pad: 32, weight: .medium)
    }
    
    // MARK: - Font Weights
    
    struct Weight {
        static let light = Font.Weight.light
        static let regular = Font.Weight.regular
        static let medium = Font.Weight.medium
        static let semibold = Font.Weight.semibold
        static let bold = Font.Weight.bold
    }
    
    // MARK: - Font Designs
    
    struct Design {
        static let `default` = Font.Design.default
        static let rounded = Font.Design.rounded
        static let monospaced = Font.Design.monospaced
        static let serif = Font.Design.serif
    }
    
    // MARK: - Predefined Font Styles
    
    /// Main note display font (large, bold, rounded) - custom size needed
    static func mainNote(isPad: Bool) -> Font {
        Size.extraLarge.font(for: isPad, design: Design.rounded)
    }
    
    /// Note marker font (medium-large, bold) - custom size needed
    static func noteMarker(isPad: Bool) -> Font {
        Size.noteMarker.font(for: isPad)
    }
    
    /// Title font (large, semibold, rounded) - custom size needed
    static func title(isPad: Bool) -> Font {
        Size.title.font(for: isPad, design: Design.rounded)
    }
    
    /// Heading font (medium-large, semibold) - custom size needed
    static func heading(isPad: Bool) -> Font {
        Size.heading.font(for: isPad)
    }
    
    /// Subheading font (medium, semibold) - use .headline
    static func subheading(isPad: Bool) -> Font {
        .headline.weight(.semibold)
    }
    
    /// Body text font (standard, medium) - use .body
    static func body(isPad: Bool) -> Font {
        .body.weight(.medium)
    }
    
    /// Caption font (small, medium) - use .caption
    static func caption(isPad: Bool) -> Font {
        .caption.weight(.medium)
    }
    
    /// Small text font (tiny, medium) - use .caption2
    static func small(isPad: Bool) -> Font {
        .caption2.weight(.medium)
    }
    
    /// Label font (tiny, medium) - use .caption2
    static func label(isPad: Bool) -> Font {
        .caption2.weight(.medium)
    }
    
    /// Frequency display font (small, medium, monospaced) - custom size needed
    static func frequency(isPad: Bool) -> Font {
        Size.frequency.font(for: isPad, design: Design.monospaced)
    }
    
    /// Cents display font (medium, semibold) - use .subheadline
    static func cents(isPad: Bool) -> Font {
        .subheadline.weight(.semibold)
    }
    
    /// Octave display font (medium, semibold) - use .subheadline
    static func octave(isPad: Bool) -> Font {
        .subheadline.weight(.semibold)
    }
    
    /// Icon font (large, light) - custom size needed
    static func icon(isPad: Bool) -> Font {
        Size.icon.font(for: isPad)
    }
    
    /// Small icon font (medium-large, medium) - custom size needed
    static func iconSmall(isPad: Bool) -> Font {
        Size.iconSmall.font(for: isPad)
    }
    
    // MARK: - Custom Font Builder
    
    /// Create a custom font with specific size, weight, and design
    static func custom(size: FontSize, design: Font.Design = .default, isPad: Bool) -> Font {
        size.font(for: isPad, design: design)
    }
    
    /// Create a custom font with specific phone and pad sizes
    static func custom(phoneSize: CGFloat, padSize: CGFloat, weight: Font.Weight = .medium, design: Font.Design = .default, isPad: Bool) -> Font {
        let size = FontSize(phone: phoneSize, pad: padSize, weight: weight)
        return size.font(for: isPad, design: design)
    }
}

// MARK: - Supporting Types

/// Represents a font size that adapts to device type
struct FontSize {
    let phone: CGFloat
    let pad: CGFloat
    let weight: Font.Weight
    
    init(phone: CGFloat, pad: CGFloat, weight: Font.Weight = .medium) {
        self.phone = phone
        self.pad = pad
        self.weight = weight
    }
    
    func value(for isPad: Bool) -> CGFloat {
        isPad ? pad : phone
    }
    
    func font(for isPad: Bool, design: Font.Design = .default) -> Font {
        .system(size: value(for: isPad), weight: weight, design: design)
    }
}

// MARK: - Font Extensions

extension View {
    /// Apply a predefined font style based on device type
    func fontStyle(_ style: (Bool) -> Font, isPad: Bool) -> some View {
        self.font(style(isPad))
    }
    
    /// Apply main note font
    func mainNoteFont(isPad: Bool) -> some View {
        self.font(FontHelper.mainNote(isPad: isPad))
    }
    
    /// Apply note marker font
    func noteMarkerFont(isPad: Bool) -> some View {
        self.font(FontHelper.noteMarker(isPad: isPad))
    }
    
    /// Apply title font
    func titleFont(isPad: Bool) -> some View {
        self.font(FontHelper.title(isPad: isPad))
    }
    
    /// Apply heading font
    func headingFont(isPad: Bool) -> some View {
        self.font(FontHelper.heading(isPad: isPad))
    }
    
    /// Apply subheading font
    func subheadingFont(isPad: Bool) -> some View {
        self.font(FontHelper.subheading(isPad: isPad))
    }
    
    /// Apply body font
    func bodyFont(isPad: Bool) -> some View {
        self.font(FontHelper.body(isPad: isPad))
    }
    
    /// Apply caption font
    func captionFont(isPad: Bool) -> some View {
        self.font(FontHelper.caption(isPad: isPad))
    }
    
    /// Apply small font
    func smallFont(isPad: Bool) -> some View {
        self.font(FontHelper.small(isPad: isPad))
    }
    
    /// Apply label font
    func labelFont(isPad: Bool) -> some View {
        self.font(FontHelper.label(isPad: isPad))
    }
    
    /// Apply frequency font
    func frequencyFont(isPad: Bool) -> some View {
        self.font(FontHelper.frequency(isPad: isPad))
    }
    
    /// Apply cents font
    func centsFont(isPad: Bool) -> some View {
        self.font(FontHelper.cents(isPad: isPad))
    }
    
    /// Apply octave font
    func octaveFont(isPad: Bool) -> some View {
        self.font(FontHelper.octave(isPad: isPad))
    }
    
    /// Apply icon font
    func iconFont(isPad: Bool) -> some View {
        self.font(FontHelper.icon(isPad: isPad))
    }
    
    /// Apply small icon font
    func iconSmallFont(isPad: Bool) -> some View {
        self.font(FontHelper.iconSmall(isPad: isPad))
    }
}
