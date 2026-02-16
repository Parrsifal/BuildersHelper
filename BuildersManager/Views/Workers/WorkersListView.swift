import SwiftUI

struct WorkersListView: View {
    @EnvironmentObject var storage: LocalStorage
    @State private var showAddWorker = false
    @State private var selectedWorker: Worker?

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if storage.workers.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(storage.workers) { worker in
                            Button {
                                selectedWorker = worker
                            } label: {
                                WorkerCardView(worker: worker)
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
        .fullScreenCover(isPresented: $showAddWorker) {
            WorkerEditView(worker: nil)
        }
        .fullScreenCover(item: $selectedWorker) { worker in
            WorkerDetailView(workerId: worker.id)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textSecondary.opacity(0.4))
            Text("No Workers Yet")
                .font(.headline)
                .foregroundColor(AppTheme.textSecondary)
            Text("Tap + to add your first worker")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary.opacity(0.7))
        }
    }

    private var addButton: some View {
        Button { showAddWorker = true } label: {
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
    WorkersListView()
        .environmentObject(LocalStorage.preview)
}
