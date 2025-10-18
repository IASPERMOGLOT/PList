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
    
    // срок годности продукта
    var expirationDateValue: Date {
            Calendar.current.date(byAdding: .day, value: expirationDate, to: addedDate) ?? Date()
        }
        
        // вычисляемое свойство: дней до истечения срока
        var daysUntilExpiration: Int {
            let components = Calendar.current.dateComponents([.day], from: Date(), to: expirationDateValue)
            return components.day ?? 0
        }
        
        // вычисляемое свойство: просрочен ли продукт
        var isExpired: Bool {
            expirationDateValue < Date()
        }
        
        // Функция для правильного склонения слова "день"
        func getDayAddition(_ num: Int) -> String {
            let preLastDigit = num % 100 / 10
            
            if preLastDigit == 1 {
                return "дней"
            }
            
            switch num % 10 {
            case 1:
                return "день"
            case 2, 3, 4:
                return "дня"
            default:
                return "дней"
            }
        }
    
    func delete(context: ModelContext) {
            context.delete(self)
        }
}
