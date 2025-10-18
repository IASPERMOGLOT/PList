import SwiftUI

struct ProductRow: View {
    var product: Product // ДОБАВИТЬ параметр продукта
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .frame(width:380, height: 100)
                .foregroundColor(Color.white)
                .shadow(radius: 5)
            
            HStack {
                //FIXME: сделать кастомное изображение
                Image(systemName: "carrot.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .foregroundColor(Color.orange)
                    .padding(20)

                Text(product.title) // ИСПОЛЬЗУЕМ название продукта
                    .font(Font.custom("", size: 25))

                
                Spacer()
                
                Image(systemName: "ellipsis.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 35)
                    .foregroundColor(Color.brightGray)
                    .padding(20)
            }
        }
    }
}

#Preview {
    let sampleProduct = Product(
        title: "Морковь",
        content: "Свежая морковь",
        image: "carrot",
        expirationDate: 7
    )
    return ProductRow(product: sampleProduct)
}
