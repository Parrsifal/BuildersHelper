import SwiftUI

struct PushPermissionView: View {
    var onAccept: () async -> Void
    var onSkip: () async -> Void

    @State private var isProcessing = false

    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Theme.primaryColor)

                VStack(spacing: 12) {
                    Text("Stay Updated")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)

                    Text("Enable notifications to receive important updates and never miss anything")
                        .font(.body)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        Task {
                            isProcessing = true
                            await onAccept()
                            isProcessing = false
                        }
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "bell.fill")
                            }
                            Text("Enable Notifications")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isProcessing)

                    Button {
                        Task {
                            await onSkip()
                        }
                    } label: {
                        Text("Maybe Later")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Theme.primaryColor)
                    }
                    .disabled(isProcessing)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    PushPermissionView(
        onAccept: {},
        onSkip: {}
    )
}
