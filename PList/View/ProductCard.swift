import SwiftUI

struct ProductCard: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Название продукта")
                            .padding()
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Готово")
                                .padding()
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.brightGray)
                            .frame(width: 370, height: 50)
                            .shadow(radius: 5)
                        
                        HStack {
                            Text("Описание, количество...")
                        }
                        .foregroundColor(Color.gray)
                    }
                    
                    
                    HStack {
                        
                        SettingButton(buttonName: "Изменить иконку", buttonImage: "pencil.and.scribble")
                        
                        SettingButton(buttonName: "Добавить фото", buttonImage: "photo")
                    }
                }
            }
            Button(action: {}) {
                Text("Удальть товар")
                    .padding()
                    .foregroundColor(Color.white)
            }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.button)
                )
                .padding()
        }
    }
}

#Preview {
    ProductCard()
}
