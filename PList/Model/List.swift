import Foundation
import SwiftData

@Model
class List: Identifiable {
    var id: UUID
    var title: String
    var productCount: Int
    var createdAt: Date
    var shareCode: String? // код общего доступа
    var isShared: Bool // общий список
    @Relationship(deleteRule: .cascade) var users: [User]
    @Relationship(deleteRule: .cascade) var products: [Product]
    
    init(id: UUID = UUID(), title: String, productCount: Int = 0, shareCode: String? = nil, isShared: Bool = false, users: [User] = [], products: [Product] = []) {
        
        self.id = id
        self.title = title
        self.productCount = productCount
        self.shareCode = shareCode
        self.isShared = isShared
        self.users = users
        self.products = products
        self.createdAt = Date()
        
    }
    
    static func createList(title: String, isShared: Bool, context: ModelContext) -> List {
            let shareCode = isShared ? generateShareCode() : nil
            let newList = List(
                title: title,
                shareCode: shareCode,
                isShared: isShared
            )
            
            context.insert(newList)
            return newList
        }
        
        // Добавление продукта в список
        func addProduct(title: String, content: String, image: String, expirationDate: Int) {
            let newProduct = Product(
                title: title,
                content: content,
                image: image,
                expirationDate: expirationDate
            )
            products.append(newProduct)
            productCount = products.count
        }
        
        // Удаление продукта из списка
        func removeProduct(_ product: Product) {
            if let index = products.firstIndex(where: { $0.id == product.id }) {
                products.remove(at: index)
                productCount = products.count
            }
        }
        
        // Генерация кода общего доступа
        private static func generateShareCode() -> String {
            let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<6).map { _ in letters.randomElement()! })
        }
        
        // Получение всех списков
        static func fetchAllLists(context: ModelContext) -> [List] {
            let descriptor = FetchDescriptor<List>(
                sortBy: [SortDescriptor<List>(\.createdAt, order: .reverse)]
            )
            do {
                return try context.fetch(descriptor)
            } catch {
                print("Ошибка загрузки списков: \(error)")
                return []
            }
        }
    
    func delete(context: ModelContext) {
            context.delete(self)
        }
}
