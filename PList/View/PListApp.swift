import SwiftUI
import SwiftData

@main
struct PListApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
        .modelContainer(for: [List.self, Product.self, User.self])
    }
}
