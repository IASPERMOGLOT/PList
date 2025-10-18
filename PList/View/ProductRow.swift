import SwiftUI

struct ProductRow: View {
    var product: Product
    
    var body: some View {
        HStack {
            // Иконка продукта
            Image(systemName: product.image)
                .resizable()
                .scaledToFit()
                .frame(width: 45)
                .foregroundColor(.button)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(Font.custom("villula-regular", size: 20))
                    .foregroundColor(.black)
                
                if !product.content.isEmpty {
                    Text(product.content)
                        .font(Font.custom("", size: 15))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Индикатор срока годности
            VStack(alignment: .trailing) {
                if (!product.isExpired) {
                    Text("\(product.daysUntilExpiration) \(product.getDayAddition(product.daysUntilExpiration))")
                        .font(Font.custom("", size: 18))
                        .foregroundColor(.green)
                } else {
                    Text("Просрочено")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}

#Preview {
    let sampleProduct = Product(
        title: "Морковь",
        content: "Свежая морковь",
        image: "carrot",
        expirationDate: 20
    )
    return ProductRow(product: sampleProduct)
}

