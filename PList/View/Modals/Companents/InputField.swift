import SwiftUI

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.button)
                
                Text(title)
                    .font(Font.custom("villula-regular", size: 16))
                    .foregroundColor(.primary)
            }
            
            TextField(placeholder, text: $text)
                .font(Font.custom("villula-regular", size: 16))
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal)
    }
}
