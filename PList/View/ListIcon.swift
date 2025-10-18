import SwiftUI

struct ListIcon: View {
    var list: List
    var iconWidth: CGFloat = 380
    var iconHeight: CGFloat = 250
    
    var body: some View {
        ZStack {
            Image("vegetables background")
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: iconWidth, height: iconHeight)
                .shadow(radius: 5)
            
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(list.title)
                        .font(Font.custom("villula-regular", size: 20))
                        .foregroundColor(Color.white)
                        .padding(3)
                    
                    HStack {
                        Text("Продуктов: \(list.products.count)")
                            .font(Font.custom("villula-regular", size: 14))
                            .foregroundColor(Color.white)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.button)
                            )
                        
                        // Индикатор совместного списка
                        if list.isShared {
                            Image(systemName: "person.2.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Circle().fill(Color.green))
                        }
                    }
                }
                
                Image("userIcon2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .padding(20)
            .frame(width: iconWidth, height: iconHeight)
        }
    }
}

#Preview {
    let sampleList = List(title: "Мой список", productCount: 5, shareCode: "ABC123", isShared: true)
    return ListIcon(list: sampleList)
}
