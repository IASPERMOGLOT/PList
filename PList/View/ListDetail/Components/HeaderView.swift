import SwiftUI

struct HeaderView: View {
    let list: ShoppingList
    let unpurchasedCount: Int
    let purchasedCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.title)
                        .font(Font.custom("villula-regular", size: 28))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        if list.isShared {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption2)
                                Text("Совместный")
                                    .font(Font.custom("villula-regular", size: 12))
                            }
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Text("Создан \(formatDate(list.createdAt))")
                            .font(Font.custom("villula-regular", size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.button, .button.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            
            StatsView(unpurchasedCount: unpurchasedCount, purchasedCount: purchasedCount)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date)
    }
}

private struct StatsView: View {
    let unpurchasedCount: Int
    let purchasedCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(unpurchasedCount + purchasedCount)", label: "Всего", icon: "number.circle.fill", color: .button)
            StatCard(value: "\(unpurchasedCount)", label: "Осталось", icon: "clock.fill", color: .orange)
            StatCard(value: "\(purchasedCount)", label: "Куплено", icon: "checkmark.circle.fill", color: .green)
        }
    }
}
