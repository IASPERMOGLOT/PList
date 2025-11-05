import SwiftUI
import SwiftData

struct UserProfile: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var userManager = UserManager.shared
    
    @State private var showingShareSheet = false
    @State private var showingJoinSheet = false
    @State private var showingEditName = false
    @State private var userName = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ProfileHeaderView(
                            userName: userManager.currentUser?.name ?? "Пользователь",
                            userID: userManager.currentUserID,
                            onEdit: { showEditName() }
                        )
                        
                        SharedListsSection(
                            onShare: { showingShareSheet = true },
                            onJoin: { showingJoinSheet = true }
                        )
                        
                        StatisticsView()
                    }
                    .padding()
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareListSheet()
        }
        .sheet(isPresented: $showingJoinSheet) {
            JoinListSheet { code in
                joinList(code: code)
            }
        }
        .sheet(isPresented: $showingEditName) {
            EditNameSheet(name: userName) { newName in
                updateUserName(newName)
            }
        }
        .onAppear {
            setupUser()
        }
    }
    
    private func setupUser() {
        _ = userManager.getCurrentUser(context: modelContext)
    }
    
    private func showEditName() {
        userName = userManager.currentUser?.name ?? ""
        showingEditName = true
    }
    
    private func updateUserName(_ name: String) {
        userManager.updateUserName(name, context: modelContext)
    }
    
    private func joinList(code: String) {
        guard !code.isEmpty else { return }
        print("Присоединяемся к списку: \(code)")
    }
}

#Preview {
    UserProfile()
        .modelContainer(for: [ShoppingList.self, Product.self, User.self])
}
