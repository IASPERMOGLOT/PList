import Foundation
import CloudKit
import SwiftData
import Combine

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    @Published var isSyncing = false
    
    private init() {}
    
    // Сохранение списка в CloudKit
    func saveList(_ list: List) {
        guard list.isShared else { return }
        
        let record = list.cloudKitRecord
        publicDatabase.save(record) { _, error in
            if let error = error {
                print("Ошибка сохранения списка: \(error)")
            } else {
                print("Список сохранен: \(list.title)")
            }
        }
    }
    
    // Обновление списка в CloudKit
    func updateList(_ list: List) {
        guard list.isShared, list.cloudKitRecordID != nil else { return }
        
        let record = list.cloudKitRecord
        publicDatabase.save(record) { _, error in
            if let error = error {
                print("Ошибка обновления списка: \(error)")
            }
        }
    }
    
    // Удаление списка из CloudKit
    func deleteList(recordID: String) {
        let recordID = CKRecord.ID(recordName: recordID)
        publicDatabase.delete(withRecordID: recordID) { _, error in
            if let error = error {
                print("Ошибка удаления списка: \(error)")
            }
        }
    }
    
    // Поиск списка по сгенерированному коду
    func findListByShareCode(_ shareCode: String, completion: @escaping (CKRecord?) -> Void) {
        let predicate = NSPredicate(format: "shareCode == %@", shareCode)
        let query = CKQuery(recordType: "SharedList", predicate: predicate)
        
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
            switch result {
            case .success(let (matchResults, _)):
                if let (_, recordResult) = matchResults.first, case .success(let record) = recordResult {
                    completion(record)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print("Ошибка поиска списка: \(error)")
                completion(nil)
            }
        }
    }
    
    // Подписка на изменения списков
    func subscribeToSharedLists() {
        let subscriptionID = "shared-lists-changes"
        let subscription = CKQuerySubscription(
            recordType: "SharedList",
            predicate: NSPredicate(value: true),
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        publicDatabase.save(subscription) { _, error in
            if let error = error {
                print("Ошибка подписки: \(error)")
            } else {
                print("Подписка создана")
            }
        }
    }
    
    // Синхронизация с CloudKit
    func syncWithCloudKit(context: ModelContext) {
        guard !isSyncing else { return }
        isSyncing = true
        
        let query = CKQuery(recordType: "SharedList", predicate: NSPredicate(value: true))
        
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 100) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (matchResults, _)):
                    self.processRecords(matchResults, context: context)
                    self.isSyncing = false
                    print("Синхронизация завершена")
                    
                case .failure(let error):
                    print("Ошибка синхронизации: \(error)")
                    self.isSyncing = false
                }
            }
        }
    }
    
    // обработка записей
    private func processRecords(_ matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], context: ModelContext) {
        for (_, recordResult) in matchResults {
            if case .success(let record) = recordResult {
                updateLocalList(from: record, context: context)
            }
        }
    }
    
    // обновление локального списка
    private func updateLocalList(from record: CKRecord, context: ModelContext) {
        let recordID = record.recordID.recordName
        
        // Поиск существующего списка
        let descriptor = FetchDescriptor<List>(
            predicate: #Predicate<List> { $0.cloudKitRecordID == recordID }
        )
        
        do {
            if let existingList = try context.fetch(descriptor).first {
                existingList.update(from: record)
            } else {
                let newList = List(
                    title: record["title"] as? String ?? "Общий список",
                    shareCode: record["shareCode"] as? String,
                    isShared: true
                )
                newList.cloudKitRecordID = recordID
                newList.update(from: record)
                context.insert(newList)
                
                // добавление текущего пользователя
                let currentUser = UserManager.shared.getCurrentUser(context: context)
                newList.addUser(currentUser)
            }
            
            try context.save()
        } catch {
            print("Ошибка обновления списка: \(error)")
        }
    }
}
