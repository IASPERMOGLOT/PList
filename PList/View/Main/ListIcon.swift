import SwiftUI

struct ListIcon: View {
    var list: ShoppingList
    var iconWidth: CGFloat = 160
    var iconHeight: CGFloat = 180
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.button.opacity(0.9),
                    Color.button.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(list.title)
                    .font(Font.custom("villula-regular", size: 18))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "cart.fill")
                            .font(.caption)
                        Text("\(list.products.count)")
                            .font(Font.custom("villula-regular", size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    if list.isShared {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(16)
            .frame(width: iconWidth, height: iconHeight)
        }
    }
}

#Preview {
    let sampleList = ShoppingList(title: "Мой список покупок", productCount: 5, shareCode: "ABC123", isShared: true)
    return ListIcon(list: sampleList)
        .padding()
        .background(Color.gray.opacity(0.1))
}
