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
                        // Профиль пользователя
                        ProfileHeaderView(
                            userName: userManager.currentUser?.name ?? "Пользователь",
                            userID: userManager.currentUserID,
                            onEdit: { showEditName() }
                        )
                        
                        // Совместные списки
                        SharedListsSection(
                            onShare: { showingShareSheet = true },
                            onJoin: { showingJoinSheet = true }
                        )
                        
                        // Статистика
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

// Компонент заголовка профиля
struct ProfileHeaderView: View {
    let userName: String
    let userID: String
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Аватар
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.button, .button.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            // Информация
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text(userName)
                        .font(Font.custom("villula-regular", size: 22))
                        .foregroundColor(.primary)
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundColor(.button)
                    }
                }
                
                Text("ID: \(userID.prefix(8))")
                    .font(Font.custom("villula-regular", size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Компонент совместных списков
struct SharedListsSection: View {
    let onShare: () -> Void
    let onJoin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Совместные списки")
                .font(Font.custom("villula-regular", size: 20))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ActionCard(
                    title: "Поделиться списком",
                    subtitle: "Предоставить доступ другим пользователям",
                    icon: "square.and.arrow.up",
                    color: .button,
                    action: onShare
                )
                
                ActionCard(
                    title: "Присоединиться к списку",
                    subtitle: "По коду доступа",
                    icon: "person.badge.plus",
                    color: .green,
                    action: onJoin
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Компонент статистики
struct StatisticsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Статистика")
                .font(Font.custom("villula-regular", size: 20))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatItem(value: "12", label: "Списков", icon: "list.bullet", color: .button)
                StatItem(value: "47", label: "Продуктов", icon: "cart", color: .green)
                StatItem(value: "38", label: "Куплено", icon: "checkmark", color: .orange)
                StatItem(value: "5", label: "Совместных", icon: "person.2", color: .purple)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Компонент карточки действия
struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Font.custom("villula-regular", size: 17))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(Font.custom("villula-regular", size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(color.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Компонент статистики
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(value)
                    .font(Font.custom("villula-regular", size: 18))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(Font.custom("villula-regular", size: 12))
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}


struct EditNameSheet: View {
    @Environment(\.dismiss) var dismiss
    let name: String
    let onSave: (String) -> Void
    
    @State private var userName: String
    
    init(name: String, onSave: @escaping (String) -> Void) {
        self.name = name
        self.onSave = onSave
        self._userName = State(initialValue: name)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.button)
                
                Text("Изменить имя")
                    .font(Font.custom("villula-regular", size: 24))
                
                TextField("Ваше имя", text: $userName)
                    .font(Font.custom("villula-regular", size: 18))
                    .padding()
                    .multilineTextAlignment(.center)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                Button("Сохранить") {
                    onSave(userName)
                    dismiss()
                }
                .disabled(userName.isEmpty)
                .padding()
                .frame(maxWidth: .infinity)
                .background(userName.isEmpty ? Color.gray : Color.button)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShareListSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShoppingList.createdAt) private var lists: [ShoppingList]
    
    var body: some View {
        NavigationView {
            VStack {
                if lists.isEmpty {
                    Text("Нет списков")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(lists) { list in
                        HStack {
                            Text(list.title)
                                .font(Font.custom("villula-regular", size: 16))
                            
                            Spacer()
                            
                            if list.isShared, let code = list.shareCode {
                                Text(code)
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(6)
                            } else {
                                Text("Личный")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                Button("Готово") {
                    dismiss()
                }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.button)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            .navigationTitle("Мои списки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct JoinListSheet: View {
    @Environment(\.dismiss) var dismiss
    let onJoin: (String) -> Void
    
    @State private var shareCode = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Text("Введите 6-значный код")
                    .font(.body)
                    .foregroundColor(.gray)
                
                TextField("Код доступа", text: $shareCode)
                    .font(Font.custom("villula-regular", size: 20))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.characters)
                    .onSubmit {
                        shareCode = shareCode.uppercased()
                    }
                
                Button("Присоединиться") {
                    let code = String(shareCode.prefix(6)).uppercased()
                    onJoin(code)
                    dismiss()
                }
                .disabled(shareCode.count != 6)
                .padding()
                .frame(maxWidth: .infinity)
                .background(shareCode.count == 6 ? Color.button : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Присоединиться к списку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    UserProfile()
        .modelContainer(for: [ShoppingList.self, Product.self, User.self])
}
