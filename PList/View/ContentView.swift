import SwiftUI

struct ContentView: View {
    var body: some View {
            ScrollView {
                
                VStack {
                    
                    HStack { //плашка профиля и моих списков
                        Spacer()
                        
                        NavigationLink(destination: UserProfile()) {
                            Text("Настройки")
                                .padding()
                                .font(Font.custom("villula-regular",size: 20))
                                .foregroundColor(Color.black) // FIXME: изменять цвет при нажатии
                        }
                    }
                    
                    
                    VStack {
                        // FIXME: отображение всех списков
                        NavigationLink(destination: OpenList()) {
                            ListIcon()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                    ZStack {
                        // при нажатии создает пустой список, при переходе в который его можно будет отредактировать
                        Button(action: {}) {
                            Text("Новый список")
                                .padding()
                                .font(Font.custom("villula-regular",size: 20))
                                .foregroundColor(Color.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.button)
                    )
                    .padding()
                    
                    
                }
            }
            .background(Color.main)
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
}
