import SwiftUI

struct SyncStatusView: View {
    let timeSinceLastSync: String
    let onSync: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("Обновлено \(timeSinceLastSync)")
                    .font(Font.custom("villula-regular", size: 12))
            }
            .foregroundColor(.green)
            
            Spacer()
            
            Button("Обновить") {
                onSync()
            }
            .font(Font.custom("villula-regular", size: 12))
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
