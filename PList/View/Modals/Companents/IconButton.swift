import SwiftUI

struct IconButton: View {
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: imageName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : .button)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.button : Color.button.opacity(0.1))
                    )
                
                if isSelected {
                    Circle()
                        .fill(Color.button)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
