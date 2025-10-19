import SwiftUI

struct SettingButton: View {
    
    var buttonName: String = "Null"
    var buttonImage: String = "camera.metering.none"
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.brightGray)
                .shadow(radius: 3)
                .frame(width: 170 ,height: 100)
            
                .padding()
            ZStack {
                VStack {
                    Image(systemName: buttonImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .padding(10)
                    
                    Text(buttonName)
                    
                }
            }
        }
    }
}

#Preview {
    SettingButton()
}
