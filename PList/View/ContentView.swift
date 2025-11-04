import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateModal = false
    @Query(sort: \ShoppingList.createdAt, order: .reverse) private var lists: [ShoppingList]
    
    var body: some View {
        ZStack {
            // Красивый градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBlue).opacity(0.1), Color(.systemGreen).opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок и настройки
                    HStack {
                        Text("Мои списки")
                            .font(Font.custom("villula-regular", size: 32))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        NavigationLink(destination: UserProfile()) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.button)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Списки продуктов
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        if lists.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "cart.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("Создайте свой первый список")
                                    .font(Font.custom("villula-regular", size: 18))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(20)
                            .gridCellColumns(2)
                        } else {
                            ForEach(lists) { list in
                                NavigationLink(destination: OpenList(list: list)) {
                                    ListIcon(list: list)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопка нового списка
                    Button(action: {
                        showingCreateModal = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Новый список")
                                .font(Font.custom("villula-regular", size: 20))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.button, Color.button.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .cornerRadius(25)
                        .shadow(color: Color.button.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
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

// Стиль для кнопок с анимацией нажатия
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
    .modelContainer(for: [ShoppingList.self, Product.self, User.self])
}
