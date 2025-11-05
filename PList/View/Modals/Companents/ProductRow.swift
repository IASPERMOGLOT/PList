import SwiftUI

struct ProductRow: View {
    var product: Product
    var onPurchase: (() -> Void)? // Колбэк для покупки
    
    var body: some View {
        HStack {
            // Иконка продукта
            Image(systemName: product.image)
                .resizable()
                .scaledToFit()
                .frame(width: 45)
                .foregroundColor(product.isPurchased ? .gray : .button)
                .opacity(product.isPurchased ? 0.6 : 1.0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(Font.custom("villula-regular", size: 20))
                    .foregroundColor(product.isPurchased ? .gray : .black)
  
                
                if !product.content.isEmpty {
                    Text(product.content)
                        .font(Font.custom("", size: 15))
                        .foregroundColor(product.isPurchased ? .gray.opacity(0.7) : .gray)
                }
                
                // инфа о сроке годности купленных продуктов
                if product.isPurchased {
                    Text("Годен до \(formatDate(product.expirationDateValue))")
                        .font(Font.custom("", size: 12))
                        .foregroundColor(product.isExpiringSoon ? .orange : .gray)
                }
            }
            
            Spacer()
            
            // Индикатор срока годности
            VStack(alignment: .trailing) {
                if product.isPurchased {
                    if product.isExpiringSoon {
                        Text("1 день!")
                            .font(Font.custom("", size: 14))
                            .foregroundColor(.orange)
                            .bold()
                    } else if product.expiresToday {
                        Text("Срок!")
                            .font(Font.custom("", size: 14))
                            .foregroundColor(.red)
                            .bold()
                    } else if product.isExpired {
                        Text("Просрочено")
                            .font(.caption2)
                            .foregroundColor(.red)
                    } else {
                        Text("\(product.daysUntilExpiration) \(product.getDayAddition(product.daysUntilExpiration))")
                            .font(Font.custom("", size: 16))
                            .foregroundColor(.green)
                    }
                } else {
                    Text("\(product.expirationDate) \(product.getDayAddition(product.expirationDate))")
                        .font(Font.custom("", size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(product.isPurchased ? Color.gray.opacity(0.1) : Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            onPurchase?()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 15) {
        ProductRow(product: Product(
            title: "Морковь",
            content: "Свежая морковь",
            image: "carrot",
            expirationDate: 7
        ))
        
        ProductRow(product: Product(
            title: "Молоко",
            content: "2.5% жирности",
            image: "cart",
            expirationDate: 3,
            isPurchased: true
        ))
        
        let expiringProduct = Product(
            title: "Йогурт",
            content: "Клубничный",
            image: "takeoutbag",
            expirationDate: 0,
            isPurchased: true
        )
        
        ProductRow(product: expiringProduct)
    }
}
