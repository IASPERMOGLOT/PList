import SwiftUI
import SwiftData

struct ShareListSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShoppingList.createdAt) private var lists: [ShoppingList]
    
    var body: some View {
        NavigationView {
            VStack {
                if lists.isEmpty {
                    EmptyListsView()
                } else {
                    ListsListView(lists: lists)
                }
                
                DoneButton(action: { dismiss() })
            }
            .navigationTitle("Мои списки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct EmptyListsView: View {
    var body: some View {
        Text("Нет списков")
            .foregroundColor(.gray)
            .padding()
    }
}

private struct ListsListView: View {
    let lists: [ShoppingList]
    
    var body: some View {
        List(lists) { list in
            HStack {
                Text(list.title)
                    .font(Font.custom("villula-regular", size: 16))
                
                Spacer()
                
                if list.isShared, let code = list.shareCode {
                    Text(code)
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                } else {
                    Text("Личный")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

private struct DoneButton: View {
    let action: () -> Void
    
    var body: some View {
        Button("Готово") {
            action()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.button)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding()
    }
}
