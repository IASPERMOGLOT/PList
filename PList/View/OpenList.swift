//
//  OpenList.swift
//  PList
//
//  Created by Александр on 11.10.2025.
//

import SwiftUI

struct OpenList: View {
    var body: some View {
        ZStack (alignment: .bottom){
            Color.main.ignoresSafeArea()
            ScrollView {
                VStack {
                    HStack { //плашка профиля и моих списков
                        Button(action: {}) {
                            Text("< Списки")
                                .padding()
                                .font(Font.custom("villula-regular",size: 20))
                                .foregroundColor(Color.black) // FIXME: изменять цвет при нажатии
                        }
                        Spacer()
                        Button(action: {}) {
                            Text("править")
                                .padding()
                                .font(Font.custom("villula-regular",size: 20))
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    //FIXME: заменить на кастомный
                    ListIcon(iconWidth: 380, iconHeight: 170)
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            // шторка поиска
            VStack {
                Capsule()
                    .fill(Color.brightGray)
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, -20)
                    
                // шаблонный поиск продуктов
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.brightGray)
                            .frame(width: 300, height: 50)
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14)
                            
                            Text("Мне нужно ...")
                        }
                        .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.green)
                }
                .padding(20)
            }
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(radius: 5)
                    .offset(y: 50)
                    .frame(height: 200)

            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    OpenList()
}
