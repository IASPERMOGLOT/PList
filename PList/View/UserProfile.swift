import SwiftUI

struct UserProfile: View {
    var body: some View {
        ScrollView {
            VStack {
                
                //FIXME: сделать редактируемую иконку
                Image("userIcon1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                
                //FIXME: сделать редактируемое имя
                Text("user name")
                
                ProfileSettingButton(buttonName: "Поделиться списком")
                
                ProfileSettingButton(buttonName: "Получить список")
                
                
                
            }
        }
        .background(Color.main)
    }
}

#Preview {
    UserProfile()
}
