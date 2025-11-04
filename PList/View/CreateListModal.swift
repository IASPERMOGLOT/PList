import SwiftUI

struct CreateListModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var listTitle: String = ""
    @State private var isSharedList: Bool = false
    var onCreateList: (String, Bool) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон с легким градиентом
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBlue).opacity(0.05), Color(.systemGreen).opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Иконка создания
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .font(.system(size: 60))
                        .foregroundColor(.button)
                        .padding(.top, 20)
                    
                    // Поле ввода названия
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Название списка")
                            .font(Font.custom("villula-regular", size: 16))
                            .foregroundColor(.primary)
                        
                        TextField("Введите название списка", text: $listTitle)
                            .font(Font.custom("villula-regular", size: 18))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Переключатель совместного доступа
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: isSharedList ? "person.2.fill" : "person.fill")
                                .foregroundColor(isSharedList ? .green : .gray)
                            
                            Toggle("Совместный список", isOn: $isSharedList)
                                .font(Font.custom("villula-regular", size: 16))
                        }
                        
                        Text(isSharedList ?
                             "Другие пользователи смогут получить доступ к списку" :
                             "Только вы будете иметь доступ к этому списку")
                            .font(Font.custom("villula-regular", size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Кнопка создания
                    Button("Создать список") {
                        if !listTitle.isEmpty {
                            onCreateList(listTitle, isSharedList)
                            dismiss()
                        }
                    }
                    .disabled(listTitle.isEmpty)
                    .font(Font.custom("villula-regular", size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                listTitle.isEmpty ? Color.gray : Color.button,
                                listTitle.isEmpty ? Color.gray.opacity(0.8) : Color.button.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .cornerRadius(25)
                        .shadow(color: listTitle.isEmpty ? .clear : Color.button.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Новый список")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .font(Font.custom("villula-regular", size: 16))
                    .foregroundColor(.button)
                }
            }
        }
    }
}

#Preview {
    CreateListModal(onCreateList: { title, isShared in
        print("Создаем: \(title), совместный: \(isShared)")
    })
}
