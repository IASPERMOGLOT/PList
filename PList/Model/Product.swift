import Foundation
import SwiftData

@Model
class Product: Identifiable {
    var id: UUID
    var title: String
    var content: String
    var image: String
    var expirationDate: Int // кол-во дней годности
    var addedDate: Date // дата добавление
    var isPurchased: Bool // куплен или нет
    var purchasedDate: Date? // дата покупки продукта
    
    init(id: UUID = UUID(), title: String, content: String, image: String, expirationDate: Int, addedDate: Date = Date(), isPurchased: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.image = image
        self.expirationDate = expirationDate
        self.addedDate = addedDate
        self.isPurchased = isPurchased
        self.purchasedDate = nil
    }
}

extension Product {
    func purchase() {
        self.isPurchased = true
        self.purchasedDate = Date() // дата покупки
    }
    
    // Отмена покупки
    func unpurchase() {
        self.isPurchased = false
        self.purchasedDate = nil
    }
    
    // переключение статуста продукта
    func togglePurchase() {
        if isPurchased {
            unpurchase()
        } else {
            purchase()
        }
    }
    
    // вычисление срока годности от даты покупки
    var expirationDateValue: Date {
        let startDate = isPurchased ? (purchasedDate ?? Date()) : addedDate
        return Calendar.current.date(byAdding: .day, value: expirationDate, to: startDate) ?? Date()
    }
    
    // количество дней до истечения срока годности
    var daysUntilExpiration: Int {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: expirationDateValue)
        return components.day ?? 0
    }
    
    // Просрочен ли продукт
    var isExpired: Bool {
        expirationDateValue < Date()
    }
    
    // Уведомление: остался 1 день до истечения срока
    var isExpiringSoon: Bool {
        daysUntilExpiration == 1 && !isExpired
    }
    
    // Уведомление: сегодня последний день
    var expiresToday: Bool {
        daysUntilExpiration == 0 && !isExpired
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
    
    // текст уведомлений
    func getExpirationNotificationText() -> String {
        if expiresToday {
            return "\(title) истекает сегодня!"
        } else if isExpiringSoon {
            return "\(title) истекает завтра!"
        } else if isExpired {
            return "\(title) просрочен!"
        }
        return ""
    }
}
