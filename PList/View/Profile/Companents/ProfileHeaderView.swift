import SwiftUI

struct ProfileHeaderView: View {
    let userName: String
    let userID: String
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.button, .button.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text(userName)
                        .font(Font.custom("villula-regular", size: 22))
                        .foregroundColor(.primary)
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundColor(.button)
                    }
                }
                
                Text("ID: \(userID.prefix(8))")
                    .font(Font.custom("villula-regular", size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
