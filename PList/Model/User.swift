import Foundation
import SwiftData
import CloudKit
import Combine

@Model
class User: Identifiable {
    var id: UUID
    var name: String
    var isCurrentUser: Bool // текущий пользователь
    var cloudKitUserID: String? // ID пользователя
    var deviceIdentifier: String // устройство
    
    init(id: UUID = UUID(), name: String, isCurrentUser: Bool = false, deviceIdentifier: String = "") {
        self.id = id
        self.name = name
        self.isCurrentUser = isCurrentUser
        self.deviceIdentifier = deviceIdentifier
        self.cloudKitUserID = UserManager.shared.currentUserID
    }
}

    // взаимодействие пользователей и CloudKit
class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User?
    @Published var isInitialized = false
    
    // Генерация ID для устройства
    var currentUserID: String {
        // сохраненный ID или создаем новый
        if let savedID = UserDefaults.standard.string(forKey: "userDeviceID") {
            return savedID
        } else {
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: "userDeviceID")
            return newID
        }
    }
    
    var currentUserName: String {
        // сохраненное имя или имя по умолчанию
        return UserDefaults.standard.string(forKey: "userName") ?? "Пользователь"
    }
    
    private init() {}
    
    func getCurrentUser(context: ModelContext) -> User {
        if let currentUser = currentUser {
            return currentUser
        }
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { $0.isCurrentUser }
        )
        
        do {
            if let existingUser = try context.fetch(descriptor).first {
                self.currentUser = existingUser
                self.isInitialized = true
                return existingUser
            }
        } catch {
            print("Ошибка поиска пользователя: \(error)")
        }
        
        // создание нового пользователя
        let newUser = User(
            name: currentUserName,
            isCurrentUser: true,
            deviceIdentifier: currentUserID
        )
        context.insert(newUser)
        self.currentUser = newUser
        self.isInitialized = true
        
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения пользователя: \(error)")
        }
        
        return newUser
    }
    
    func updateCurrentUser(name: String, context: ModelContext) {
        let user = getCurrentUser(context: context)
        user.name = name
        UserDefaults.standard.set(name, forKey: "userName")
        
        do {
            try context.save()
            self.currentUser = user
        } catch {
            print("Ошибка обновления пользователя: \(error)")
        }
    }
    
    // Сброс пользователя (FIXME: убрать)
    func resetUser(context: ModelContext) {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { $0.isCurrentUser }
        )
        
        do {
            let users = try context.fetch(descriptor)
            for user in users {
                context.delete(user)
            }
            self.currentUser = nil
            self.isInitialized = false
            try context.save()
        } catch {
            print("Ошибка сброса пользователя: \(error)")
        }
    }
}
