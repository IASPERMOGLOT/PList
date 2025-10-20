import Foundation
import SwiftData
internal import CloudKit

@Model
class ShoppingList: Identifiable {
    var id: UUID
    var title: String
    var productCount: Int
    var createdAt: Date
    var shareCode: String?
    var isShared: Bool
    var cloudKitRecordID: String?
    @Relationship(deleteRule: .cascade) var users: [User]
    @Relationship(deleteRule: .cascade) var products: [Product]
    
    init(id: UUID = UUID(), title: String, productCount: Int = 0, shareCode: String? = nil,
         isShared: Bool = false, users: [User] = [], products: [Product] = []) {
        self.id = id
        self.title = title
        self.productCount = productCount
        self.shareCode = shareCode
        self.isShared = isShared
        self.users = users
        self.products = products
        self.createdAt = Date()
    }
}

// MARK: - CloudKit Extension
extension ShoppingList {
    var cloudKitRecord: CKRecord {
        let record: CKRecord
        if let recordID = cloudKitRecordID {
            record = CKRecord(recordType: "SharedList", recordID: CKRecord.ID(recordName: recordID))
        } else {
            record = CKRecord(recordType: "SharedList")
            cloudKitRecordID = record.recordID.recordName
        }
        
        record["title"] = title
        record["shareCode"] = shareCode
        record["isShared"] = isShared ? 1 : 0
        record["createdAt"] = createdAt
        
        return record
    }
    
    func update(from record: CKRecord) {
        title = record["title"] as? String ?? title
        shareCode = record["shareCode"] as? String
        isShared = (record["isShared"] as? Int ?? 0) == 1
    }
}

// MARK: - Business Logic
extension ShoppingList {
    static func createList(title: String, isShared: Bool, context: ModelContext) -> ShoppingList {
        let shareCode = isShared ? generateShareCode() : nil
        let newList = ShoppingList(title: title, shareCode: shareCode, isShared: isShared)
        context.insert(newList)
        return newList
    }
    
    func addProduct(title: String, content: String, image: String, expirationDate: Int) {
        let newProduct = Product(title: title, content: content, image: image, expirationDate: expirationDate)
        products.append(newProduct)
        productCount = products.count
    }
    
    func removeProduct(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products.remove(at: index)
            productCount = products.count
        }
    }
    
    func addUser(_ user: User) {
        if !users.contains(where: { $0.id == user.id }) {
            users.append(user)
        }
    }
    
    func delete(context: ModelContext) {
        context.delete(self)
    }
    
    private static func generateShareCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    static func findListByShareCode(_ shareCode: String, context: ModelContext) -> ShoppingList? {
        let descriptor = FetchDescriptor<ShoppingList>(
            predicate: #Predicate<ShoppingList> { $0.shareCode == shareCode }
        )
        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Ошибка поиска: \(error)")
            return nil
        }
    }
}
