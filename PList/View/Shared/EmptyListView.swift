import SwiftUI

struct EmptyListView: View {
    let isShared: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isShared ? "person.2.circle" : "cart.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            VStack(spacing: 8) {
                Text(isShared ? "Совместный список пуст" : "Список пуст")
                    .font(Font.custom("villula-regular", size: 20))
                    .foregroundColor(.primary)
                
                Text(isShared ?
                     "Добавьте продукты или подождите синхронизации" :
                     "Добавьте первый продукт в список")
                    .font(Font.custom("villula-regular", size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
