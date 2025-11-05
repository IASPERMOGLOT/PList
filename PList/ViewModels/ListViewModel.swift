import Foundation
import SwiftData
import Combine
import FirebaseFirestore

@MainActor
class ListViewModel: ObservableObject {
    @Published var lists: [ShoppingList] = []
    @Published var sharedLists: [ShoppingList] = []
    @Published var isLoading = false
    @Published var syncError: String?
    @Published var lastSyncTime = Date()
    
    private var modelContext: ModelContext
    private let firebaseManager = FirebaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Кэш для связи Firebase ID и локальных объектов
    private var firebaseToListMap: [String: ShoppingList] = [:]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupFirebaseListeners()
        fetchLocalLists()
    }
    
    // ИСПРАВЛЕНИЕ: Метод для обновления ModelContext
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        fetchLocalLists()
    }
    
    // MARK: - Firebase Integration
    private func setupFirebaseListeners() {
        // Слушаем изменения списков из Firebase
        firebaseManager.listenToUserLists { [weak self] firebaseLists in
            self?.processFirebaseLists(firebaseLists)
        }
    }
    
    private func processFirebaseLists(_ firebaseLists: [FirebaseList]) {
        Task { @MainActor in
            for firebaseList in firebaseLists {
                await syncListFromFirebase(firebaseList)
            }
            fetchLocalLists()
            lastSyncTime = Date()
        }
    }
    
    private func syncListFromFirebase(_ firebaseList: FirebaseList) async {
        guard let firebaseId = firebaseList.id else { return }
        
        // Ищем локальный список по Firebase ID
        if let localList = findListByFirebaseId(firebaseId) {
            // Обновляем существующий список
            await updateLocalList(localList, with: firebaseList)
        } else {
            // Создаем новый список из Firebase
            await createLocalList(from: firebaseList)
        }
        
        // Синхронизируем продукты для этого списка
        await syncProductsForList(firebaseId)
    }
    
    private func syncProductsForList(_ firebaseListId: String) async {
        firebaseManager.listenToListProducts(listId: firebaseListId) { [weak self] firebaseProducts in
            Task { @MainActor in
                guard let self = self,
                      let localList = self.findListByFirebaseId(firebaseListId) else { return }
                
                self.syncProducts(for: localList, with: firebaseProducts)
                self.fetchLocalLists()
            }
        }
    }
    
    // MARK: - Public Methods
    
    public func fetchLocalLists() {
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
        // Создаем локально
        let localList = ShoppingList.createList(title: title, isShared: isShared, context: modelContext)
        saveContext()
        fetchLocalLists()
        
        // Синхронизируем с Firebase
        Task {
            do {
                let firebaseId = try await firebaseManager.createList(title: title, isShared: isShared)
                print("✅ Список синхронизирован с Firebase: \(firebaseId)")
            } catch {
                print("❌ Ошибка создания списка в Firebase: \(error)")
                syncError = "Не удалось создать общий список: \(error.localizedDescription)"
            }
        }
    }
    
    func joinList(shareCode: String, completion: @escaping (Bool, String) -> Void) {
        let cleanCode = shareCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard cleanCode.count == 6 else {
            completion(false, "Код должен содержать 6 символов")
            return
        }
        
        Task {
            do {
                let listId = try await firebaseManager.joinList(shareCode: cleanCode)
                completion(true, "Успешно присоединились к списку")
                print("✅ Присоединились к списку в Firebase: \(listId)")
            } catch {
                completion(false, "Список с кодом \(cleanCode) не найден")
                print("❌ Ошибка присоединения к списку: \(error)")
            }
        }
    }
    
    func addProduct(to list: ShoppingList, product: Product) {
        // Добавляем локально
        list.addProduct(
            title: product.title,
            content: product.content,
            image: product.image,
            expirationDate: product.expirationDate
        )
        saveContext()
        fetchLocalLists()
        
        // Синхронизируем с Firebase
        if let firebaseId = getFirebaseId(for: list) {
            Task {
                do {
                    try await firebaseManager.addProduct(to: firebaseId, product: product)
                    print("✅ Продукт синхронизирован с Firebase")
                } catch {
                    print("❌ Ошибка синхронизации продукта: \(error)")
                    syncError = "Ошибка синхронизации: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func toggleProductPurchase(_ product: Product, in list: ShoppingList) {
        let oldValue = product.isPurchased
        product.togglePurchase()
        saveContext()
        fetchLocalLists()
        
        // Обновляем уведомления
        if product.isPurchased {
            NotificationManager.shared.scheduleExpirationNotification(for: product)
        } else {
            NotificationManager.shared.removePendingNotification(for: product.id.uuidString)
        }
        
        // Синхронизируем с Firebase
        if let firebaseId = getFirebaseId(for: list) {
            Task {
                do {
                    try await firebaseManager.updateProductPurchaseStatus(
                        listId: firebaseId,
                        productId: product.id.uuidString,
                        isPurchased: product.isPurchased,
                        purchasedDate: product.purchasedDate
                    )
                } catch {
                    print("❌ Ошибка синхронизации статуса покупки: \(error)")
                    // Откатываем локальное изменение в случае ошибки
                    await MainActor.run {
                        if product.isPurchased != oldValue {
                            product.togglePurchase()
                            self.saveContext()
                        }
                    }
                }
            }
        }
    }
    
    func deleteProduct(_ product: Product, from list: ShoppingList) {
        NotificationManager.shared.removePendingNotification(for: product.id.uuidString)
        list.removeProduct(product)
        saveContext()
        fetchLocalLists()
        
        // Синхронизируем с Firebase
        if let firebaseId = getFirebaseId(for: list) {
            Task {
                do {
                    try await firebaseManager.deleteProduct(listId: firebaseId, productId: product.id.uuidString)
                } catch {
                    print("❌ Ошибка удаления продукта из Firebase: \(error)")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func findListByFirebaseId(_ firebaseId: String) -> ShoppingList? {
        // Временная реализация - можно добавить поле firebaseId в ShoppingList
        return lists.first { $0.title.contains(firebaseId.prefix(8)) } ??
               sharedLists.first { $0.title.contains(firebaseId.prefix(8)) }
    }
    
    private func getFirebaseId(for list: ShoppingList) -> String? {
        // Временная реализация
        return firebaseToListMap.first(where: { $0.value.id == list.id })?.key
    }
    
    private func updateLocalList(_ localList: ShoppingList, with firebaseList: FirebaseList) async {
        // Обновляем данные списка из Firebase
        // Можно добавить логику разрешения конфликтов
        localList.title = firebaseList.title
        localList.isShared = firebaseList.isShared
        localList.shareCode = firebaseList.shareCode
        localList.lastModified = firebaseList.lastModifiedDate
        saveContext()
    }
    
    private func createLocalList(from firebaseList: FirebaseList) async {
        // Создаем локальный список из Firebase данных
        let newList = ShoppingList(
            title: firebaseList.title,
            shareCode: firebaseList.shareCode,
            isShared: firebaseList.isShared
        )
        newList.createdAt = firebaseList.createdAtDate
        newList.lastModified = firebaseList.lastModifiedDate
        
        modelContext.insert(newList)
        saveContext()
        
        // Сохраняем связь
        if let firebaseId = firebaseList.id {
            firebaseToListMap[firebaseId] = newList
        }
    }
    
    private func syncProducts(for localList: ShoppingList, with firebaseProducts: [FirebaseProduct]) {
        // Синхронизируем продукты между локальными и Firebase данными
        // Удаляем старые продукты
        localList.products.removeAll()
        
        // Добавляем продукты из Firebase
        for firebaseProduct in firebaseProducts {
            let product = Product(
                id: UUID(uuidString: firebaseProduct.id ?? UUID().uuidString) ?? UUID(),
                title: firebaseProduct.title,
                content: firebaseProduct.content,
                image: firebaseProduct.image,
                expirationDate: firebaseProduct.expirationDate,
                addedDate: firebaseProduct.addedDateValue,
                isPurchased: firebaseProduct.isPurchased
            )
            product.purchasedDate = firebaseProduct.purchasedDateValue
            
            localList.products.append(product)
        }
        
        localList.productCount = localList.products.count
        saveContext()
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("❌ Ошибка сохранения: \(error)")
            syncError = "Ошибка сохранения: \(error.localizedDescription)"
        }
    }
}
