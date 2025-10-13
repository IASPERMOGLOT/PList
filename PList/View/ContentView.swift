//
//  ContentView.swift
//  PList
//
//  Created by Александр on 11.10.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack {
                    
                    HStack { //плашка профиля и моих списков
                        Button(action: {}) {
                            Text("Мои списки")
                                .padding()
                                .font(Font.custom("villula-regular",size: 20))
                                .foregroundColor(Color.black) // FIXME: изменять цвет при нажатии
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Настройки")
                                .padding()
                                .font(Font.custom("villula-regular",size: 20))
                                .foregroundColor(Color.black) // FIXME: изменять цвет при нажатии
                        }
                    }
                    
                    
                    VStack {
                        // FIXME: отображение всех списков
                        ListIcon()
                    }
                    
                    ZStack {
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
}

#Preview {
    ContentView()
}
