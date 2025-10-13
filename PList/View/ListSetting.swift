//
//  ListSetting.swift
//  PList
//
//  Created by Александр on 13.10.2025.
//

import SwiftUI

struct ListSetting: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Название списка")
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
                Text("Удальть список")
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
    ListSetting()
}
