import Foundation
import SwiftData
import UIKit

@Model
class User: Identifiable {
    var id: UUID
    var name: String
    var isCurrentUser: Bool
    
    init(id: UUID = UUID(), name: String, isCurrentUser: Bool = false) {
        self.id = id
        self.name = name
        self.isCurrentUser = isCurrentUser
    }
}
