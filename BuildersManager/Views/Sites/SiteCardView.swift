import SwiftUI

struct SiteCardView: View {
    let site: Site
    let workerCount: Int

    var body: some View {
        HStack(spacing: 12) {
            siteImage

            VStack(alignment: .leading, spacing: 6) {
                Text(site.name.isEmpty ? "Unnamed Site" : site.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(site.deadline, style: .date)
                        .font(.caption)
                }
                .foregroundColor(deadlineColor)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                        Text("\(workerCount)")
                            .font(.caption)
                    }
                    .foregroundColor(AppTheme.textSecondary)

                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption2)
                        Text(formatBudget(site.budget))
                            .font(.caption)
                    }
                    .foregroundColor(AppTheme.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary.opacity(0.5))
        }
        .cardStyle()
    }

    @ViewBuilder
    private var siteImage: some View {
        if let data = site.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
        } else {
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.accent.opacity(0.12))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "building.2")
                        .font(.title3)
                        .foregroundColor(AppTheme.accent)
                )
        }
    }

    private var deadlineColor: Color {
        site.deadline < Date() ? AppTheme.destructive : AppTheme.textSecondary
    }

    private func formatBudget(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", value / 1_000)
        }
        return String(format: "$%.0f", value)
    }
}

#Preview {
    let storage = LocalStorage.preview
    SiteCardView(site: storage.sites[0], workerCount: storage.sites[0].workerIds.count)
        .padding()
}
