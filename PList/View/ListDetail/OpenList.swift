import SwiftUI
import SwiftData

struct OpenList: View {
    var list: ShoppingList
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddProductModal = false
    @State private var showingDeleteAlert = false
    @State private var productToDelete: Product?
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
                HeaderView(list: list, unpurchasedCount: unpurchasedProducts.count, purchasedCount: purchasedProducts.count)
                
                if list.isShared {
                    SyncStatusView(
                        timeSinceLastSync: timeSinceLastSync,
                        onSync: { syncList() }
                    )
                }
                
                ProductsListView(
                    unpurchasedProducts: unpurchasedProducts,
                    purchasedProducts: purchasedProducts,
                    isShared: list.isShared,
                    onTogglePurchase: togglePurchase,
                    onDeleteProduct: { product in
                        productToDelete = product
                        showingDeleteAlert = true
                    }
                )
            }
            
            AddProductButton(action: { showingAddProductModal = true })
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
        lastUpdateTime = Date()
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
