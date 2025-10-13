//
//  ProfileSettingButton.swift
//  PList
//
//  Created by Александр on 12.10.2025.
//

import SwiftUI

struct ProfileSettingButton: View {
    
    var buttonName: String = "None"
    
    var body: some View {
        Button(action: {}) {
            Text(buttonName)
                .padding()
                .font(Font.custom("", size: 15))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            Rectangle()
                .fill(Color.green)
        )
    }
}

#Preview {
    ProfileSettingButton()
}
