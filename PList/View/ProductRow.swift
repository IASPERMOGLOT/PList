//
//  ProductRow.swift
//  PList
//
//  Created by Александр on 11.10.2025.
//

import SwiftUI

struct ProductRow: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .frame(width:380, height: 100)
                .foregroundColor(Color.white)
                .shadow(radius: 5)
            
            HStack {
                //FIXME: сделать кастомное изображение
                Image(systemName: "carrot.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .foregroundColor(Color.orange)
                    .padding(20)

                Text("Морковь")
                    .font(Font.custom("", size: 25))

                
                Spacer()
                
                Image(systemName: "ellipsis.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 35)
                    .foregroundColor(Color.brightGray)
                    .padding(20)
            }
        }
    }
}

#Preview {
    ProductRow()
}
