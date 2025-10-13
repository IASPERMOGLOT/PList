//
//  UsersList.swift
//  PList
//
//  Created by Александр on 13.10.2025.
//

import SwiftUI

struct UsersList: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Пользователи")
                Divider()
                    .overlay(Color.main)
                    .frame(height: 15)
                ProfileSettingButton(buttonName: "UserName")
            }
        }
        .background(Color.main)
    }
}

#Preview {
    UsersList()
}
