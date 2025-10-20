import Foundation
import SwiftData
import CloudKit

@Model
class List: Identifiable {
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
    
    
    // создание общего списка и его запись
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
    
    // обновление данных
    func update(from record: CKRecord) {
        title = record["title"] as? String ?? title
        shareCode = record["shareCode"] as? String
        isShared = (record["isShared"] as? Int ?? 0) == 1
    }
    
    // создание спи ка
    static func createList(title: String, isShared: Bool, context: ModelContext) -> List {
        let shareCode = isShared ? generateShareCode() : nil
        let newList = List(title: title, shareCode: shareCode, isShared: isShared)
        
        context.insert(newList)
        
        if isShared {
            CloudKitManager.shared.saveList(newList)
        }
        
        return newList
    }
    
    // добавление продукта
    func addProduct(title: String, content: String, image: String, expirationDate: Int) {
        let newProduct = Product(title: title, content: content, image: image, expirationDate: expirationDate)
        products.append(newProduct)
        productCount = products.count
        
        if isShared {
            CloudKitManager.shared.updateList(self)
        }
    }
    
    // удаление продукта
    func removeProduct(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products.remove(at: index)
            productCount = products.count
            
            if isShared {
                CloudKitManager.shared.updateList(self)
            }
        }
    }
    
    // добавление пользователя в список
    func addUser(_ user: User) {
        if !users.contains(where: { $0.id == user.id }) {
            users.append(user)
            
            if isShared {
                CloudKitManager.shared.updateList(self)
            }
        }
    }
    
    
    // удаление списка
    func delete(context: ModelContext) {
        if isShared, let recordID = cloudKitRecordID {
            CloudKitManager.shared.deleteList(recordID: recordID)
        }
        context.delete(self)
    }
    
    // генерация кода для списка
    private static func generateShareCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    // поиск кода по коду
    static func findListByShareCode(_ shareCode: String, context: ModelContext) -> List? {
        let descriptor = FetchDescriptor<List>(
            predicate: #Predicate<List> { $0.shareCode == shareCode }
        )
        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Ошибка поиска списка: \(error)")
            return nil
        }
    }
    
}
