import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateModal = false
    @Query(sort: \ShoppingList.createdAt, order: .reverse) private var lists: [ShoppingList]
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    
                    NavigationLink(destination: UserProfile()) {
                        Text("Настройки")
                            .padding()
                            .font(Font.custom("villula-regular",size: 20))
                            .foregroundColor(Color.black)
                    }
                }
                .padding(.horizontal)
                
                VStack {
                    if lists.isEmpty {
                        Text("Создайте свой первый список")
                            .font(Font.custom("villula-regular", size: 25))
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(lists) { list in
                            NavigationLink(destination: OpenList(list: list)) {
                                ListIcon(list: list)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .padding()
                
                ZStack {
                    Button(action: {
                        showingCreateModal = true
                    }) {
                        Text("Новый список")
                            .padding()
                            .font(Font.custom("villula-regular",size: 20))
                            .foregroundColor(Color.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.button)
                )
                .padding()
            }
        }
        .background(Color.main)
        .sheet(isPresented: $showingCreateModal) {
            CreateListModal(onCreateList: { title, isShared in
                createList(title: title, isShared: isShared)
            })
        }
    }
    
    private func createList(title: String, isShared: Bool) {
        _ = ShoppingList.createList(title: title, isShared: isShared, context: modelContext)
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка при создании списка: \(error)")
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
    .modelContainer(for: [ShoppingList.self, Product.self, User.self])
}
