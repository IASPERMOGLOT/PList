import Foundation
import SwiftData
import Combine


//Совместные списки
//Кастомные иконки продуктов + их разнообразие
@MainActor
class ListViewModel: ObservableObject {
    @Published var lists: [List] = []
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchLists()
    }
    
    func fetchLists() {
        let descriptor = FetchDescriptor<List>(
            sortBy: [SortDescriptor<List>(\.createdAt, order: .reverse)]
        )
        
        do {
            lists = try modelContext.fetch(descriptor)
        } catch {
            print("Ошибка загрузки списков: \(error)")
            lists = []
        }
    }
    
    func createList(title: String, isShared: Bool) {
        let shareCode = isShared ? generateShareCode() : nil
        let newList = List(
            title: title,
            shareCode: shareCode,
            isShared: isShared
        )
        
        modelContext.insert(newList)
        
        do {
            try modelContext.save()
            // После сохранения список сразу обновляется
            fetchLists()
        } catch {
            print("Ошибка при создании списка: \(error)")
        }
    }
    
    private func generateShareCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}
