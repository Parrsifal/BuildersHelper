import SwiftUI

struct Theme {

    // MARK: - Colors (Light theme with orange accent, matching AppTheme)

    static let primaryColor = Color(red: 1.0, green: 0.55, blue: 0.0) // Orange (#FF8C00)
    static let secondaryColor = Color(red: 1.0, green: 0.7, blue: 0.3)
    static let accentColor = Color(red: 1.0, green: 0.55, blue: 0.0)

    static let backgroundColor = Color(red: 0.96, green: 0.96, blue: 0.97) // Light gray (#F5F5F7)
    static let cardBackground = Color.white
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.12) // Dark (#1A1A1E)
    static let textSecondary = Color(red: 0.45, green: 0.47, blue: 0.53) // Medium gray (#737B87)
    static let dividerColor = Color(red: 0.85, green: 0.85, blue: 0.87)

    // MARK: - Gradients

    static let primaryGradient = LinearGradient(
        colors: [primaryColor, secondaryColor],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [cardBackground, backgroundColor],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Shadows

    static let cardShadow = Color.black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 6
    static let glowShadow = primaryColor.opacity(0.3)

    // MARK: - Spacing

    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24

    // MARK: - Corner Radius

    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 20
}
