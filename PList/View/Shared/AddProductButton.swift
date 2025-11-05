import SwiftUI

struct AddProductButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                
                Text("Добавить продукт")
                    .font(Font.custom("villula-regular", size: 16))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.button)
            .cornerRadius(25)
            .shadow(color: Color.button.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.bottom, 20)
    }
}
