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
            ScrollView {
                VStack(spacing: 25) {
                    userInfoSection
                    sharedListsSection
                }
                .padding()
            }
            .background(Color.main)
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
    
    private var userInfoSection: some View {
        VStack(spacing: 15) {
            Image("userIcon1")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
            
            HStack {
                Text("Пользователь")
                    .font(Font.custom("villula-regular", size: 20))
                    .foregroundColor(.black)
                
                Button(action: { showEditName() }) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.button)
                        .font(.title2)
                }
            }
            
            Text("ID: \(userManager.currentUserID.prefix(8))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    private var sharedListsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Совместные списки")
                .font(Font.custom("villula-regular", size: 20))
                .foregroundColor(.black)
            
            VStack(spacing: 12) {
                actionButton(
                    title: "Поделиться списком",
                    icon: "square.and.arrow.up",
                    color: .button,
                    action: { showingShareSheet = true }
                )
                
                actionButton(
                    title: "Присоединиться к списку",
                    icon: "person.badge.plus",
                    color: .green,
                    action: { showingJoinSheet = true }
                )
            }
            
            // FIXME: добавить синхронизацию

        }
    }
    
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(Font.custom("villula-regular", size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(color)
            .cornerRadius(12)
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
