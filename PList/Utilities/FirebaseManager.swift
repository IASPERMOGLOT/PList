import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isSyncing = false
    @Published var lastError: String?
    @Published var isConnected = false
    @Published var isInitialized = false
    
    private init() {
        checkFirebaseConnection()
        // Временно отключаем аутентификацию
        // setupAuth()
    }
    
    // MARK: - Connection Check
    private func checkFirebaseConnection() {
        // Проверяем, что Firebase инициализирован
        if FirebaseApp.app() != nil {
            isInitialized = true
            print("✅ Firebase успешно инициализирован")
            testFirestoreConnection()
        } else {
            lastError = "Firebase не инициализирован"
            print("❌ Firebase не инициализирован")
        }
    }
    
    // MARK: - Test Firestore Connection
    private func testFirestoreConnection() {
        let testDoc = db.collection("connection_test").document("app_status")
        
        testDoc.setData([
            "appName": "ShoppingListApp",
            "testedAt": Timestamp(date: Date()),
            "status": "testing"
        ]) { [weak self] error in
            if let error = error {
                print("❌ Firestore test failed: \(error)")
                self?.isConnected = false
                self?.lastError = error.localizedDescription
            } else {
                print("✅ Firestore connection test passed")
                self?.isConnected = true
                self?.lastError = nil
                
                // Удаляем тестовый документ
                testDoc.delete()
            }
        }
    }
    
    // MARK: - User Management (упрощенная версия)
    func getCurrentUserID() -> String {
        // Временно используем device ID
        return UIDevice.current.identifierForVendor?.uuidString ?? "device_\(UUID().uuidString.prefix(8))"
    }
    
    // MARK: - Lists Management
    func createList(title: String, isShared: Bool) async throws -> String {
        guard isInitialized else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase не инициализирован"])
        }
        
        let listData: [String: Any] = [
            "title": title,
            "isShared": isShared,
            "shareCode": isShared ? generateShareCode() : nil,
            "createdBy": getCurrentUserID(),
            "createdAt": Timestamp(date: Date()),
            "lastModified": Timestamp(date: Date()),
            "members": [getCurrentUserID()]
        ]
        
        let documentRef = try await db.collection("shoppingLists").addDocument(data: listData)
        print("✅ Список создан в Firebase: \(documentRef.documentID)")
        return documentRef.documentID
    }
    
    func joinList(shareCode: String) async throws -> String {
        guard isInitialized else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase не инициализирован"])
        }
        
        let query = db.collection("shoppingLists")
            .whereField("shareCode", isEqualTo: shareCode)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        guard let document = snapshot.documents.first else {
            throw NSError(domain: "FirebaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Список с кодом \(shareCode) не найден"])
        }
        
        let listId = document.documentID
        let currentUserID = getCurrentUserID()
        
        // Добавляем пользователя в список участников
        try await db.collection("shoppingLists").document(listId).updateData([
            "members": FieldValue.arrayUnion([currentUserID]),
            "lastModified": Timestamp(date: Date())
        ])
        
        print("✅ Пользователь присоединился к списку: \(listId)")
        return listId
    }
    
    // MARK: - Real-time Updates
    func listenToUserLists(completion: @escaping ([FirebaseList]) -> Void) {
        guard isInitialized else {
            print("⚠️ Firebase не инициализирован, слушатель отключен")
            completion([])
            return
        }
        
        let currentUserID = getCurrentUserID()
        
        print("🎧 Запускаем слушатель списков для пользователя: \(currentUserID)")
        
        db.collection("shoppingLists")
            .whereField("members", arrayContains: currentUserID)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Ошибка слушателя списков: \(error)")
                    self.lastError = error.localizedDescription
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("📭 Нет списков для пользователя")
                    completion([])
                    return
                }
                
                print("📥 Получено списков: \(documents.count)")
                let lists = documents.compactMap { document -> FirebaseList? in
                    try? document.data(as: FirebaseList.self)
                }
                
                completion(lists)
            }
    }
    
    func listenToListProducts(listId: String, completion: @escaping ([FirebaseProduct]) -> Void) {
        guard isInitialized else {
            completion([])
            return
        }
        
        db.collection("shoppingLists")
            .document(listId)
            .collection("products")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Ошибка слушателя продуктов: \(error)")
                    self.lastError = error.localizedDescription
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let products = documents.compactMap { document -> FirebaseProduct? in
                    try? document.data(as: FirebaseProduct.self)
                }
                
                completion(products)
            }
    }
    
    // MARK: - Products Management
    func addProduct(to listId: String, product: Product) async throws {
        guard isInitialized else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase не инициализирован"])
        }
        
        let productData: [String: Any] = [
            "id": product.id.uuidString,
            "title": product.title,
            "content": product.content,
            "image": product.image,
            "expirationDate": product.expirationDate,
            "addedDate": Timestamp(date: product.addedDate),
            "isPurchased": product.isPurchased,
            "purchasedDate": product.purchasedDate.map { Timestamp(date: $0) } as Any,
            "createdBy": getCurrentUserID(),
            "createdAt": Timestamp(date: Date())
        ]
        
        try await db.collection("shoppingLists")
            .document(listId)
            .collection("products")
            .document(product.id.uuidString)
            .setData(productData)
        
        // Обновляем время изменения списка
        try await updateListLastModified(listId: listId)
        
        print("✅ Продукт добавлен в Firebase: \(product.title)")
    }
    
    func updateProductPurchaseStatus(listId: String, productId: String, isPurchased: Bool, purchasedDate: Date?) async throws {
        guard isInitialized else { return }
        
        var updateData: [String: Any] = [
            "isPurchased": isPurchased,
            "lastModified": Timestamp(date: Date())
        ]
        
        if let purchasedDate = purchasedDate {
            updateData["purchasedDate"] = Timestamp(date: purchasedDate)
        } else {
            updateData["purchasedDate"] = FieldValue.delete()
        }
        
        try await db.collection("shoppingLists")
            .document(listId)
            .collection("products")
            .document(productId)
            .updateData(updateData)
        
        try await updateListLastModified(listId: listId)
        
        print("✅ Статус продукта обновлен: \(productId) - \(isPurchased ? "куплен" : "не куплен")")
    }
    
    func deleteProduct(listId: String, productId: String) async throws {
        guard isInitialized else { return }
        
        try await db.collection("shoppingLists")
            .document(listId)
            .collection("products")
            .document(productId)
            .delete()
        
        try await updateListLastModified(listId: listId)
        
        print("✅ Продукт удален из Firebase: \(productId)")
    }
    
    // MARK: - Private Methods
    private func updateListLastModified(listId: String) async throws {
        try await db.collection("shoppingLists")
            .document(listId)
            .updateData([
                "lastModified": Timestamp(date: Date())
            ])
    }
    
    private func generateShareCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}

// MARK: - Firebase Data Models
struct FirebaseList: Codable, Identifiable {
    @DocumentID var id: String?
    let title: String
    let isShared: Bool
    let shareCode: String?
    let createdBy: String
    let members: [String]
    let createdAt: Timestamp
    let lastModified: Timestamp
    
    var createdAtDate: Date { createdAt.dateValue() }
    var lastModifiedDate: Date { lastModified.dateValue() }
}

struct FirebaseProduct: Codable, Identifiable {
    @DocumentID var id: String?
    let title: String
    let content: String
    let image: String
    let expirationDate: Int
    let addedDate: Timestamp
    let isPurchased: Bool
    let purchasedDate: Timestamp?
    let createdBy: String
    let createdAt: Timestamp
    
    var addedDateValue: Date { addedDate.dateValue() }
    var purchasedDateValue: Date? { purchasedDate?.dateValue() }
    var createdAtDate: Date { createdAt.dateValue() }
}
