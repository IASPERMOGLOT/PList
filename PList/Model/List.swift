import Foundation
import SwiftData

@Model
class List: Identifiable {
    var id: UUID
    var title: String
    var productCount: Int
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
        
    }
    
    // гинератор кода
    func generateShareCode() -> String {
            let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let code = String((0..<6).map { _ in characters.randomElement()! })
            self.shareCode = code
            self.isShared = true
            return code
        }
}
