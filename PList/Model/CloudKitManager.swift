import Foundation
internal import CloudKit
import SwiftData
import Combine

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    @Published var isSyncing = false
    
    private init() {}
    
    // Универсальные методы работы с CloudKit
    func saveRecord(_ record: CKRecord) {
        publicDatabase.save(record) { _, error in
            if let error = error {
                print("Ошибка сохранения: \(error)")
            }
        }
    }
    
    func updateRecord(_ record: CKRecord) {
        publicDatabase.save(record) { _, error in
            if let error = error {
                print("Ошибка обновления: \(error)")
            }
        }
    }
    
    func deleteRecord(recordID: String) {
        let recordID = CKRecord.ID(recordName: recordID)
        publicDatabase.delete(withRecordID: recordID) { _, error in
            if let error = error {
                print("Ошибка удаления: \(error)")
            }
        }
    }
    
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
                print("Ошибка поиска: \(error)")
                completion(nil)
            }
        }
    }
    
    func subscribeToSharedLists() {
        let subscriptionID = "shared-lists-changes"
        let subscription = CKQuerySubscription(
            recordType: "SharedList",
            predicate: NSPredicate(value: true),
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        publicDatabase.save(subscription) { _, error in
            if let error = error {
                print("Ошибка подписки: \(error)")
            }
        }
    }
    
    func syncWithCloudKit(context: ModelContext) {
        guard !isSyncing else { return }
        isSyncing = true
        
        let query = CKQuery(recordType: "SharedList", predicate: NSPredicate(value: true))
        
        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 50) { result in
            DispatchQueue.main.async {
                self.isSyncing = false
                
                if case .success(let (matchResults, _)) = result {
                    print("Синхронизация завершена")
                } else if case .failure(let error) = result {
                    print("Ошибка синхронизации: \(error)")
                }
            }
        }
    }
}
