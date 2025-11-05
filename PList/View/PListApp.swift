import SwiftUI
import SwiftData

@main
struct PListApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ShoppingList.self,
            Product.self,
            User.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
