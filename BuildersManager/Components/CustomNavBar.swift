import SwiftUI

struct CustomNavBar: View {
    let title: String
    var onSettingsTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Button(action: onSettingsTap) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(AppTheme.accent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.background)
    }
}

#Preview {
    CustomNavBar(title: "Sites", onSettingsTap: {})
}
