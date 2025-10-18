import Foundation
import SwiftData

@Model
class User: Identifiable {
    var id: UUID
    var name: String
    var isCurrentUser: Bool // текущий пользователь
    
    init(id: UUID = UUID(), name: String, isCurrentUser: Bool = false) {
        self.id = id
        self.name = name
        self.isCurrentUser = isCurrentUser
    }
}
