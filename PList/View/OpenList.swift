import SwiftUI
import SwiftData

struct OpenList: View {
    var list: ShoppingList
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddProductModal = false
    @State private var showingDeleteAlert = false
    @State private var productToDelete: Product?
    
    // Для индикатора синхронизации
    @State private var lastUpdateTime = Date()
    
    private var unpurchasedProducts: [Product] {
        list.products.filter { !$0.isPurchased }
            .sorted { $0.addedDate > $1.addedDate }
    }
    
    private var purchasedProducts: [Product] {
        list.products.filter { $0.isPurchased }
            .sorted { ($0.purchasedDate ?? Date()) > ($1.purchasedDate ?? Date()) }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Хедер
                HeaderView(list: list, unpurchasedCount: unpurchasedProducts.count, purchasedCount: purchasedProducts.count)
                
                // Индикатор синхронизации для совместных списков
                if list.isShared {
                    SyncStatusView(
                        timeSinceLastSync: timeSinceLastSync,
                        onSync: { syncList() }
                    )
                }
                
                // Список продуктов
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Некупленные продукты
                        if !unpurchasedProducts.isEmpty {
                            ProductSection(count: unpurchasedProducts.count, icon: "cart.fill", color: .orange) {
                                ForEach(unpurchasedProducts) { product in
                                    ModernProductRow(product: product, onPurchase: {
                                        togglePurchase(product)
                                    }, onDelete: {
                                        productToDelete = product
                                        showingDeleteAlert = true
                                    })
                                }
                            }
                        }
                        
                        // Купленные продукты
                        if !purchasedProducts.isEmpty {
                            ProductSection(count: purchasedProducts.count, icon: "checkmark.circle.fill", color: .green) {
                                ForEach(purchasedProducts) { product in
                                    ModernProductRow(product: product, onPurchase: {
                                        togglePurchase(product)
                                    }, onDelete: {
                                        productToDelete = product
                                        showingDeleteAlert = true
                                    })
                                }
                            }
                        }
                        
                        if list.products.isEmpty {
                            EmptyListView(isShared: list.isShared)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            
            // Кнопка добавления
            AddProductButton {
                showingAddProductModal = true
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddProductModal) {
            CreateProductModal(list: list) { title, description, image, days in
                addProduct(title: title, description: description, image: image, expirationDays: days)
            }
        }
        .alert("Удалить продукт?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                if let product = productToDelete {
                    deleteProduct(product)
                }
            }
        } message: {
            Text("Продукт \"\(productToDelete?.title ?? "")\" будет удален из списка.")
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
    
    // Обновляем индикатор времени
    private var timeSinceLastSync: String {
        let interval = Date().timeIntervalSince(lastUpdateTime)
        if interval < 60 {
            return "только что"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) мин назад"
        } else {
            let hours = Int(interval / 3600)
            return "\(hours) ч назад"
        }
    }
    
    private func syncList() {
        // SwiftData автоматически синхронизируется
        // Просто обновляем время
        lastUpdateTime = Date()
        print("🔄 Синхронизация SwiftData")
    }
    
    private func addProduct(title: String, description: String, image: String, expirationDays: Int) {
        list.addProduct(
            title: title,
            content: description,
            image: image,
            expirationDate: expirationDays
        )
        saveContext()
        lastUpdateTime = Date()
    }
    
    private func togglePurchase(_ product: Product) {
        product.togglePurchase()
        saveContext()
        lastUpdateTime = Date()
        
        if product.isPurchased {
            NotificationManager.shared.scheduleExpirationNotification(for: product)
        } else {
            NotificationManager.shared.removePendingNotification(for: product.id.uuidString)
        }
    }
    
    private func deleteProduct(_ product: Product) {
        NotificationManager.shared.removePendingNotification(for: product.id.uuidString)
        list.removeProduct(product)
        saveContext()
        lastUpdateTime = Date()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
}

// Обновляем SyncStatusView для SwiftData
struct SyncStatusView: View {
    let timeSinceLastSync: String
    let onSync: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                Text("Обновлено \(timeSinceLastSync)")
                    .font(Font.custom("villula-regular", size: 12))
            }
            .foregroundColor(.green)
            
            Spacer()
            
            Button("Обновить") {
                onSync()
            }
            .font(Font.custom("villula-regular", size: 12))
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// Обновленное пустое состояние
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


// Обновленная строка продукта с исправленным onChange
struct ModernProductRow: View {
    let product: Product
    let onPurchase: () -> Void
    let onDelete: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Чекбокс покупки
            PurchaseButton(isPurchased: product.isPurchased, action: onPurchase)
            
            // Информация о продукте
            ProductInfoView(product: product)
            
            Spacer()
            
            // Бейдж срока годности
            ExpirationIndicator(product: product)
            
            // Кнопка удаления
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(product.isPurchased ? Color.gray.opacity(0.05) : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(product.isPurchased ? Color.green.opacity(0.2) : Color.gray.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .onChange(of: product.isPurchased) { oldValue, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = false
                }
            }
        }
    }
}

// Компонент информации о продукте
struct ProductInfoView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                // Иконка продукта
                Image(systemName: product.image)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(product.isPurchased ? .gray : .button)
                    .frame(width: 20)
                
                Text(product.title)
                    .font(Font.custom("villula-regular", size: 17))
                    .foregroundColor(product.isPurchased ? .gray : .primary)
                    .strikethrough(product.isPurchased, color: .gray)
            }
            
            if !product.content.isEmpty {
                Text(product.content)
                    .font(Font.custom("villula-regular", size: 14))
                    .foregroundColor(product.isPurchased ? .gray.opacity(0.7) : .secondary)
                    .padding(.leading, 28)
            }
            
            if product.isPurchased {
                Text("Годен до \(formatDate(product.expirationDateValue))")
                    .font(Font.custom("villula-regular", size: 12))
                    .foregroundColor(expirationColor)
                    .padding(.leading, 28)
            }
        }
    }
    
    private var expirationColor: Color {
        if product.isExpired { return .red }
        if product.expiresToday { return .orange }
        if product.isExpiringSoon { return .orange }
        return .gray
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date)
    }
}

// Хедер с статистикой
struct HeaderView: View {
    let list: ShoppingList
    let unpurchasedCount: Int
    let purchasedCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок и иконка
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.title)
                        .font(Font.custom("villula-regular", size: 28))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        if list.isShared {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption2)
                                Text("Совместный")
                                    .font(Font.custom("villula-regular", size: 12))
                            }
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Text("Создан \(formatDate(list.createdAt))")
                            .font(Font.custom("villula-regular", size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Иконка списка
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.button, .button.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            
            // Статистика
            HStack(spacing: 12) {
                StatCard(
                    value: "\(unpurchasedCount + purchasedCount)",
                    label: "Всего",
                    icon: "number.circle.fill",
                    color: .button
                )
                
                StatCard(
                    value: "\(unpurchasedCount)",
                    label: "Осталось",
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatCard(
                    value: "\(purchasedCount)",
                    label: "Куплено",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date)
    }
}

// Карточка статистики
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(value)
                    .font(Font.custom("villula-regular", size: 16))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(Font.custom("villula-regular", size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Секция продуктов
struct ProductSection<Content: View>: View {
    let count: Int
    let icon: String
    let color: Color
    let content: Content
    
    init(count: Int, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.count = count
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text("\(count)")
                        .font(Font.custom("villula-regular", size: 18))
                } icon: {
                    Image(systemName: icon)
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// Кнопка покупки с анимацией
struct PurchaseButton: View {
    let isPurchased: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isPurchased ? Color.green : Color.gray.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                if isPurchased {
                    Image(systemName: "checkmark")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Индикатор срока годности
struct ExpirationIndicator: View {
    let product: Product
    
    var body: some View {
        VStack(spacing: 2) {
            if product.isPurchased {
                Group {
                    if product.isExpiringSoon {
                        Text("1 день!")
                    } else if product.expiresToday {
                        Text("Срок!")
                    } else if product.isExpired {
                        Text("Просрочено")
                    } else {
                        Text("\(product.daysUntilExpiration)д")
                    }
                }
                .font(Font.custom("villula-regular", size: 10))
                .foregroundColor(expirationTextColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(expirationBackgroundColor.opacity(0.2))
                .cornerRadius(6)
            } else {
                Text("\(product.expirationDate)д")
                    .font(Font.custom("villula-regular", size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var expirationTextColor: Color {
        if product.isExpired || product.expiresToday { return .red }
        if product.isExpiringSoon { return .orange }
        return .green
    }
    
    private var expirationBackgroundColor: Color {
        if product.isExpired || product.expiresToday { return .red }
        if product.isExpiringSoon { return .orange }
        return .green
    }
}

// Кнопка добавления продукта
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

// Extension для скругления определенных углов
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Добавляем Label для iOS 14+ совместимости
extension View {
    func labelStyle() -> some View {
        self
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ShoppingList.self, Product.self, User.self, configurations: config)
    
    let sampleList = ShoppingList(title: "Продукты на неделю", productCount: 4, isShared: true)
    
    let product1 = Product(title: "Молоко", content: "2.5%", image: "cart", expirationDate: 5)
    let product2 = Product(title: "Яблоки", content: "Красные", image: "apple", expirationDate: 7)
    let product3 = Product(title: "Хлеб", content: "Бородинский", image: "leaf", expirationDate: 3, isPurchased: true)
    let product4 = Product(title: "Сыр", content: "Российский", image: "takeoutbag", expirationDate: 10, isPurchased: true)
    
    sampleList.products = [product1, product2, product3, product4]
    
    return NavigationView {
        OpenList(list: sampleList)
            .modelContainer(container)
    }
}
