import SwiftUI
import SwiftData

struct OpenList: View {
    var list: List
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddProductModal = false
    
    // Разделяем продукты на купленные и некупленные
    private var unpurchasedProducts: [Product] {
        list.products.filter { !$0.isPurchased }
            .sorted { $0.addedDate > $1.addedDate } // Сначала новые
    }
    
    private var purchasedProducts: [Product] {
        list.products.filter { $0.isPurchased }
            .sorted { ($0.purchasedDate ?? Date()) > ($1.purchasedDate ?? Date()) } // Сначала недавно купленные
    }
    
    var body: some View {
        ZStack (alignment: .bottom) {
            ScrollView {
                VStack {
                    ListIcon(list: list, iconWidth: 380, iconHeight: 170)
                    
                    Divider()
                        .overlay(Color.main)
                        .frame(height: 15)
                    
                    // Отображаем продукты списка
                    VStack (spacing: 10) {
                        // Некупленные продукты
                        ForEach(unpurchasedProducts) { product in
                            ProductRow(product: product) {
                                togglePurchase(product)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteProduct(product)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                            .contextMenu {
                                Button {
                                    togglePurchase(product)
                                } label: {
                                    Label("Отметить купленным", systemImage: "checkmark.circle")
                                }
                                
                                Button(role: .destructive) {
                                    deleteProduct(product)
                                } label: {
                                    Label("Удалить продукт", systemImage: "trash")
                                }
                            }
                        }
                        
                        // Разделитель между купленными и некупленными продуктами
                        if !unpurchasedProducts.isEmpty && !purchasedProducts.isEmpty {
                            Divider()
                                .padding(.vertical, 2)
                                .overlay(Color.green.opacity(0.5))
                            
                            Text("Купленные")
                                .font(Font.custom("villula-regular", size: 16))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 25)
                        }
                        
                        // Купленные продукты
                        ForEach(purchasedProducts) { product in
                            ProductRow(product: product) {
                                togglePurchase(product)
                            }
                            
                            // удаление продукта свайпом
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteProduct(product)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                            
                            // вернуть продукт свайпом
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    togglePurchase(product)
                                } label: {
                                    Label("Вернуть", systemImage: "arrow.uturn.left")
                                }
                                .tint(.blue)
                            }
                            //меню при зажатии продукта (вернуть в список/ удалить продукт)
                            .contextMenu {
                                Button {
                                    togglePurchase(product)
                                } label: {
                                    Label("Вернуть в список", systemImage: "arrow.uturn.left")
                                }
                                
                                Button(role: .destructive) {
                                    deleteProduct(product)
                                } label: {
                                    Label("Удалить продукт", systemImage: "trash")
                                }
                            }
                        }
                        
                        // пустой ли лист
                        if list.products.isEmpty {
                            Text("Список пуст")
                                .font(Font.custom("villula-regular", size: 16))
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            
            HStack {
                Spacer()
                // кнопка добавления продуктов
                Button(action: {
                    showingAddProductModal = true
                }) {
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.green)
                }
            }
            .padding(20)
        }
        .background(Color.main.ignoresSafeArea())
        .navigationTitle(list.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddProductModal) {
            CreateProductModal { title, description, image, days in
                addProduct(title: title, description: description, image: image, expirationDays: days)
            }
        }
        // действия со списком через toolbar
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if !purchasedProducts.isEmpty {
                        Button {
                            unpurchaseAllProducts()
                        } label: {
                            Label("Вернуть все купленные", systemImage: "arrow.uturn.left")
                        }
                    }
                    
                    Button(role: .destructive) {
                        deleteEntireList()
                    } label: {
                        Label("Удалить весь список", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            // Запрашиваем разрешение на уведомления при открытии списка
            NotificationManager.shared.requestAuthorization()
        }
    }
    
    private func addProduct(title: String, description: String, image: String, expirationDays: Int) {
        list.addProduct(
            title: title,
            content: description,
            image: image,
            expirationDate: expirationDays
        )
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка при сохранении продукта: \(error)")
        }
    }
    
    private func togglePurchase(_ product: Product) {
        product.togglePurchase()
        
        do {
            try modelContext.save()
            
            // Управление уведомлениями
            if product.isPurchased {
                // Если купили - планируем уведомление
                NotificationManager.shared.scheduleExpirationNotification(for: product)
            } else {
                // Если вернули - удаляем уведомление
                NotificationManager.shared.removePendingNotification(for: product.id.uuidString)
            }
            
        } catch {
            print("Ошибка при изменении статуса продукта: \(error)")
        }
    }
    
    private func unpurchaseAllProducts() {
        purchasedProducts.forEach { product in
            product.unpurchase()
            // удаление уведомления для продуктов, которые были возвращены из категории "куплены"
            NotificationManager.shared.removePendingNotification(for: product.id.uuidString)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка при возврате всех продуктов: \(error)")
        }
    }
    
    private func deleteProduct(_ product: Product) {
        // если удалили продук = удалили для него уведомление
        NotificationManager.shared.removePendingNotification(for: product.id.uuidString)
        
        list.removeProduct(product)
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка при удалении конкретного продукта: \(error)")
        }
    }
    
    private func deleteEntireList() {
        // удалили список = удалили все уведомления
        list.products.forEach { product in
            NotificationManager.shared.removePendingNotification(for: product.id.uuidString)
        }
        
        list.delete(context: modelContext)
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка при удалении списка: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: List.self, Product.self, User.self, configurations: config)
    
    let sampleList = List(title: "Тестовый список", productCount: 4, isShared: false)
    
    // Добавляем тестовые продукты
    let product1 = Product(
        title: "Молоко",
        content: "коровье",
        image: "cart",
        expirationDate: 5
    )
    
    let product2 = Product(
        title: "Яблоки",
        content: "Красные",
        image: "apple",
        expirationDate: 7
    )
    
    let product3 = Product(
        title: "Хлеб",
        content: "Белый",
        image: "leaf",
        expirationDate: 3,
        isPurchased: true
    )
    
    let product4 = Product(
        title: "Сыр",
        content: "Твердый",
        image: "takeoutbag",
        expirationDate: 10,
        isPurchased: true
    )
    
    sampleList.products = [product1, product2, product3, product4]
    
    return NavigationView {
        OpenList(list: sampleList)
            .modelContainer(container)
    }
}
