import Foundation
import SwiftData

class ListViewModel {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
        } catch {
            print("Ошибка при создании списка: \(error)")
        }
    }
    
    private func generateShareCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}
