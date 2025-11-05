import SwiftUI

struct StatisticsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика")
                .font(Font.custom("villula-regular", size: 20))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatItem(value: "12", label: "Списков", icon: "list.bullet", color: .button)
                StatItem(value: "47", label: "Продуктов", icon: "cart", color: .green)
                StatItem(value: "38", label: "Куплено", icon: "checkmark", color: .orange)
                StatItem(value: "5", label: "Совместных", icon: "person.2", color: .purple)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(value)
                    .font(Font.custom("villula-regular", size: 18))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(Font.custom("villula-regular", size: 12))
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
