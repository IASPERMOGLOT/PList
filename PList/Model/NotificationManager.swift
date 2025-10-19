// NotificationManager.swift
import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationPermissionGranted: Bool = false
    
    private init() {}
    
    // Запрос разрешения на уведомления
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = granted
                if granted {
                    print("Разрешение на уведомления получено")
                } else if let error = error {
                    print("Ошибка запроса уведомлений: \(error)")
                }
            }
        }
    }
    
    // Проверка текущего статуса разрешений
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // Планирование уведомления для продукта
    func scheduleExpirationNotification(for product: Product) {
        guard product.isPurchased,
              let purchasedDate = product.purchasedDate,
              !product.isExpired else { return }
        
        // Удаляем старые уведомления для этого продукта
        removePendingNotification(for: product.id.uuidString)
        
        // Уведомление за 1 день до истечения срока
        let notificationDate = Calendar.current.date(byAdding: .day, value: product.expirationDate - 1, to: purchasedDate)!
        
        // Создаем уведомление
        let content = UNMutableNotificationContent()
        content.title = "Срок годности истекает"
        content.body = product.getExpirationNotificationText()
        content.sound = .default
        
        // Триггер на конкретную дату
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Запрос уведомления
        let request = UNNotificationRequest(
            identifier: product.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка планирования уведомления: \(error)")
            } else {
                print("Уведомление запланировано для продукта \(product.title) на \(notificationDate)")
            }
        }
    }
    
    // Удаление уведомления для продукта
    func removePendingNotification(for productId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [productId])
    }
    
    // Планирование уведомлений для всех продуктов в списке
    func scheduleNotifications(for products: [Product]) {
        for product in products {
            scheduleExpirationNotification(for: product)
        }
    }
    
    // Удаление всех уведомлений
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
