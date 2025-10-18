import SwiftUI

struct ListSetting: View {
    var list: List // ДОБАВИТЬ параметр списка
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text(list.title) // ИСПОЛЬЗУЕМ название из списка
                            .padding()
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Готово")
                                .padding()
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    HStack {
                        SettingButton(buttonName: "Изменить название", buttonImage: "pencil.and.scribble")
                        
                        SettingButton(buttonName: "Изменить фон", buttonImage: "photo")
                    }
                    
                    HStack {
                        SettingButton(buttonName: "Пользователи", buttonImage: "person")
                        
                        SettingButton(buttonName: "Активность", buttonImage: "clock")
                    }
                }
            }
            Button(action: {}) {
                Text("Удалить список")
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
    let sampleList = List(title: "Мой список", productCount: 5)
    return ListSetting(list: sampleList)
}
