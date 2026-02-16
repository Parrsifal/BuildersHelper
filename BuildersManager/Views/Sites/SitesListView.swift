import SwiftUI

struct SitesListView: View {
    @EnvironmentObject var storage: LocalStorage
    @State private var showAddSite = false
    @State private var selectedSite: Site?

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if storage.sites.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(storage.sites) { site in
                            Button {
                                selectedSite = site
                            } label: {
                                SiteCardView(
                                    site: site,
                                    workerCount: site.workerIds.count
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
        }
        .fullScreenCover(isPresented: $showAddSite) {
            SiteEditView(site: nil)
        }
        .fullScreenCover(item: $selectedSite) { site in
            SiteDetailView(siteId: site.id)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textSecondary.opacity(0.4))
            Text("No Sites Yet")
                .font(.headline)
                .foregroundColor(AppTheme.textSecondary)
            Text("Tap + to add your first construction site")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary.opacity(0.7))
        }
    }

    private var addButton: some View {
        Button { showAddSite = true } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(AppTheme.accent)
                .clipShape(Circle())
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 6, x: 0, y: 3)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 16)
    }
}

#Preview {
    SitesListView()
        .environmentObject(LocalStorage.preview)
}
