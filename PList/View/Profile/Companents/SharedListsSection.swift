import SwiftUI

struct SharedListsSection: View {
    let onShare: () -> Void
    let onJoin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Совместные списки")
                .font(Font.custom("villula-regular", size: 20))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ActionCard(
                    title: "Поделиться списком",
                    subtitle: "Предоставить доступ другим пользователям",
                    icon: "square.and.arrow.up",
                    color: .button,
                    action: onShare
                )
                
                ActionCard(
                    title: "Присоединиться к списку",
                    subtitle: "По коду доступа",
                    icon: "person.badge.plus",
                    color: .green,
                    action: onJoin
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Font.custom("villula-regular", size: 17))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(Font.custom("villula-regular", size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(color.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
