import Foundation
import SwiftData
import Combine
internal import CloudKit

@MainActor
class ListViewModel: ObservableObject {
    @Published var lists: [ShoppingList] = []
    @Published var sharedLists: [ShoppingList] = []
    @Published var isLoading = false
    
    private let modelContext: ModelContext
    private let cloudKitManager = CloudKitManager.shared
    
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
            print("Ошибка загрузки списков: \(error)")
            lists = []
            sharedLists = []
        }
        
        isLoading = false
    }
    
    func createList(title: String, isShared: Bool) {
        let newList = ShoppingList.createList(title: title, isShared: isShared, context: modelContext)
        
        // Сохраняем в CloudKit если список общий
        if isShared {
            let record = newList.cloudKitRecord
            cloudKitManager.saveRecord(record)
        }
        
        do {
            try modelContext.save()
            fetchLists()
        } catch {
            print("Ошибка при создании списка: \(error)")
        }
    }
    
    // Поделиться списком (сделать общим)
    func shareList(_ list: ShoppingList) {
        list.isShared = true
        list.shareCode = generateShareCode()
        
        // Сохраняем в CloudKit
        let record = list.cloudKitRecord
        cloudKitManager.saveRecord(record)
        
        do {
            try modelContext.save()
            fetchLists()
        } catch {
            print("Ошибка при создании общего списка: \(error)")
        }
    }
    
    // Прекратить совместный доступ
    func stopSharingList(_ list: ShoppingList) {
        list.isShared = false
        
        // Удаляем из CloudKit
        if let recordID = list.cloudKitRecordID {
            cloudKitManager.deleteRecord(recordID: recordID)
        }
        
        do {
            try modelContext.save()
            fetchLists()
        } catch {
            print("Ошибка при отключении общего доступа: \(error)")
        }
    }
    
    // Присоединение к списку по коду
    func joinList(shareCode: String, completion: @escaping (Bool, String) -> Void) {
        guard shareCode.count == 6 else {
            completion(false, "Код должен содержать 6 символов")
            return
        }
        
        // Ищем локально
        if let localList = ShoppingList.findListByShareCode(shareCode, context: modelContext) {
            let currentUser = UserManager.shared.getCurrentUser(context: modelContext)
            localList.addUser(currentUser)
            
            do {
                try modelContext.save()
                fetchLists()
                completion(true, "Успешно присоединились к списку: \(localList.title)")
            } catch {
                completion(false, "Ошибка присоединения к списку")
            }
            return
        }
        
        // Ищем в CloudKit
        cloudKitManager.findListByShareCode(shareCode) { [weak self] record in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let record = record {
                    // Создаем локальную копию списка из CloudKit
                    let newList = ShoppingList(
                        title: record["title"] as? String ?? "Общий список",
                        shareCode: shareCode,
                        isShared: true
                    )
                    newList.cloudKitRecordID = record.recordID.recordName
                    newList.update(from: record)
                    
                    // Добавляем текущего пользователя
                    let currentUser = UserManager.shared.getCurrentUser(context: self.modelContext)
                    newList.addUser(currentUser)
                    
                    self.modelContext.insert(newList)
                    
                    do {
                        try self.modelContext.save()
                        self.fetchLists()
                        completion(true, "Успешно присоединились к списку: \(newList.title)")
                    } catch {
                        completion(false, "Ошибка сохранения списка")
                    }
                } else {
                    completion(false, "Список с кодом \(shareCode) не найден")
                }
            }
        }
    }
    
    // Синхронизация с CloudKit
    func syncWithCloudKit() {
        cloudKitManager.syncWithCloudKit(context: modelContext)
        // Обновляем данные после синхронизации
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.fetchLists()
        }
    }
    
    // Обновление списка в CloudKit
    func updateListInCloud(_ list: ShoppingList) {
        guard list.isShared else { return }
        
        let record = list.cloudKitRecord
        cloudKitManager.updateRecord(record)
    }
    
    private func generateShareCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}
