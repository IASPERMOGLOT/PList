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
    
}
