//
//  LoadingScreeen.swift
//  PList
//
//  Created by Александр on 11.10.2025.
//

import SwiftUI

struct LoadingScreeen: View {
    var body: some View {
        ZStack {
            Color.main.ignoresSafeArea() // поменять на mainColor
            VStack {
                Image("shopping-bag")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 222)
                    .padding()
                ProgressView()
                
            }
        }
    }
}

#Preview {
    LoadingScreeen()
}
