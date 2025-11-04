import Foundation
import SwiftData
internal import CloudKit
import Combine

@MainActor
class SharedListManager: ObservableObject {
    static let shared = SharedListManager()
    
    private let cloudKitManager = CloudKitManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var lastUpdateTime = Date()
    
    private init() {
        // Подписка на изменения каждые 10 секунд
        Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkForUpdates()
            }
            .store(in: &cancellables)
    }
    
    // Синхронизация конкретного списка
    func syncList(_ list: ShoppingList, context: ModelContext) {
        guard list.isShared, let shareCode = list.shareCode else { return }
        
        cloudKitManager.findListByShareCode(shareCode) { record in
            DispatchQueue.main.async {
                if let record = record {
                    self.updateLocalList(from: record, context: context)
                }
            }
        }
    }
    
    // Обновление локального списка из CloudKit
    private func updateLocalList(from record: CKRecord, context: ModelContext) {
        guard let shareCode = record["shareCode"] as? String,
              let localList = ShoppingList.findListByShareCode(shareCode, context: context) else { return }
        
        // Обновляем базовые данные
        localList.update(from: record)
        
        // TODO: Здесь нужно синхронизировать продукты
        // Это сложная часть - нужно сравнивать и синхронизировать продукты
        
        do {
            try context.save()
            lastUpdateTime = Date()
        } catch {
            print("Ошибка синхронизации списка: \(error)")
        }
    }
    
    // Отправка изменений в CloudKit
    func pushListChanges(_ list: ShoppingList) {
        guard list.isShared else { return }
        
        let record = list.cloudKitRecord
        cloudKitManager.updateRecord(record)
    }
    
    // Проверка обновлений
    func checkForUpdates() {
        //проверка через CloudKit subscriptions
        print("Проверка обновлений...")
    }
}
