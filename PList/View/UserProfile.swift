
import SwiftUI

struct UserProfile: View {
    var body: some View {
        ScrollView {
            VStack {
                
                
                HStack { //плашка профиля и моих списков
                    Button(action: {}) {
                        Text("Профиль")
                            .padding()
                            .font(Font.custom("villula-regular",size: 20))
                            .foregroundColor(Color.black) // FIXME: изменять цвет при нажатии
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Мои списки")
                            .padding()
                            .font(Font.custom("villula-regular",size: 20))
                            .foregroundColor(Color.black) // FIXME: изменять цвет при нажатии
                    }
                }
                
                //FIXME: сделать редактируемую иконку
                Image("userIcon1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                
                //FIXME: сделать редактируемое имя
                Text("user name")
                
                ProfileSettingButton(buttonName: "Поделиться списком")
                
                ProfileSettingButton(buttonName: "Получить список")
                
                ProfileSettingButton(buttonName: "Создать групповой список")
                
                

                
                
            }
        }
    }
}

#Preview {
    UserProfile()
}
