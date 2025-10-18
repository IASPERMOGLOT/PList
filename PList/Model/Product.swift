import Foundation
import SwiftData

@Model
class Product: Identifiable {
    var id: UUID
    var title: String
    var content: String
    var image: String
    var expirationDate: Int // дни годности продукта
    var addedDate: Date // когда добавили продукт
    
    init(id: UUID = UUID(), title: String, content: String, image: String, expirationDate: Int, addedDate: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.image = image
        self.expirationDate = expirationDate
        self.addedDate = addedDate
    }
    
    // вычисление срока годности
    var expirationDateValue: Date {
        Calendar.current.date(byAdding: .day, value: expirationDate, to: addedDate) ?? Date()
    }
}
