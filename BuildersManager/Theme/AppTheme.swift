import SwiftUI

enum AppTheme {
    static let accent = Color(red: 1.0, green: 0.55, blue: 0.0)
    static let background = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let cardBackground = Color.white
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.12)
    static let textSecondary = Color(red: 0.45, green: 0.47, blue: 0.53)
    static let success = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let destructive = Color(red: 0.9, green: 0.25, blue: 0.2)

    static let cornerRadius: CGFloat = 14
    static let smallCornerRadius: CGFloat = 10
    static let cardPadding: CGFloat = 14
    static let shadowRadius: CGFloat = 3
    static let shadowY: CGFloat = 2
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.cardPadding)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: Color.black.opacity(0.06), radius: AppTheme.shadowRadius, x: 0, y: AppTheme.shadowY)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
