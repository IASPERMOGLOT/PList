import Foundation
import SwiftData
import Combine

@MainActor
class ListViewModel: ObservableObject {
    @Published var lists: [ShoppingList] = []
    @Published var sharedLists: [ShoppingList] = []
    @Published var isLoading = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchLists()
    }
    
    func fetchLists() {
        isLoading = true
        
        let descriptor = FetchDescriptor<ShoppingList>(
            sortBy: [SortDescriptor<ShoppingList>(\.createdAt, order: .reverse)]
        )
        
        do {
            let allLists = try modelContext.fetch(descriptor)
            lists = allLists.filter { !$0.isShared }
            sharedLists = allLists.filter { $0.isShared }
        } catch {
            print("❌ Ошибка загрузки списков: \(error)")
            lists = []
            sharedLists = []
        }
        
        isLoading = false
    }
    
    func createList(title: String, isShared: Bool) {
        _ = ShoppingList.createList(title: title, isShared: isShared, context: modelContext)
        saveContext()
        fetchLists()
    }
    
    func shareList(_ list: ShoppingList) {
        list.isShared = true
        list.shareCode = generateShareCode()
        list.markAsModified()
        saveContext()
        fetchLists()
    }
    
    func stopSharingList(_ list: ShoppingList) {
        list.isShared = false
        list.shareCode = nil
        list.markAsModified()
        saveContext()
        fetchLists()
    }
    
    func joinList(shareCode: String, completion: @escaping (Bool, String) -> Void) {
        let cleanCode = shareCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard cleanCode.count == 6 else {
            completion(false, "Код должен содержать 6 символов")
            return
        }
        
        if let localList = ShoppingList.findListByShareCode(cleanCode, context: modelContext) {
            let currentUser = UserManager.shared.getCurrentUser(context: modelContext)
            localList.addUser(currentUser)
            saveContext()
            fetchLists()
            completion(true, "Успешно присоединились к списку: \(localList.title)")
        } else {
            completion(false, "Список с кодом \(cleanCode) не найден")
        }
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("❌ Ошибка сохранения: \(error)")
        }
    }
    
    private func generateShareCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}
