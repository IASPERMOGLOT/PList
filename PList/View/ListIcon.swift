import SwiftUI

struct ListIcon: View {
    
    var iconWidth: CGFloat = 380
    var iconHeight: CGFloat = 250
    
    var body: some View {
        ZStack {

            //FIXME: Сделать кастомные фоны списков
            Image("vegetables background")
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: iconWidth, height: iconHeight)
            
            ZStack(alignment: .topLeading) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Название списка")
                        .font(Font.custom("villula-regular", size: 20))
                        .foregroundColor(Color.white)
                        .padding(3)
                    
                    Text("Кол-во продуктов: ...")
                        .font(Font.custom("villula-regular", size: 14))
                        .foregroundColor(Color.white)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.button)
                        )
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
    ListIcon()
}
