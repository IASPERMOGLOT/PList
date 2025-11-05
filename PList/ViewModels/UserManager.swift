import Foundation
import SwiftData
import UIKit
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User?
    
    var currentUserID: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    var currentUserName: String {
        return UIDevice.current.name
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
                currentUser = existingUser
                return existingUser
            }
        } catch {
            print("Ошибка поиска пользователя: \(error)")
        }
        
        let newUser = User(name: currentUserName, isCurrentUser: true)
        context.insert(newUser)
        currentUser = newUser
        
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения пользователя: \(error)")
        }
        
        return newUser
    }
    
    func updateUserName(_ name: String, context: ModelContext) {
        let user = getCurrentUser(context: context)
        user.name = name
        
        do {
            try context.save()
            currentUser = user
        } catch {
            print("Ошибка обновления имени: \(error)")
        }
    }
}
