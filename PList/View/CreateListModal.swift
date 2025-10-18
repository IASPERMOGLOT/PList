import SwiftUI

struct CreateListModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var listTitle: String = ""
    @State private var isSharedList: Bool = false
    var onCreateList: (String, Bool) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) { // ЗАМЕНИТЬ ScrollView на VStack
                TextField("Введите название списка", text: $listTitle)
                    .font(Font.custom("villula-regular", size: 15))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(radius: 3)
                    )
                    .padding(.horizontal)
                
                Toggle("Совместный список", isOn: $isSharedList)
                    .padding(.horizontal)
                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                
                Text(isSharedList ?
                     "Другие пользователи смогут получить доступ к списку" :
                     "Только вы будете иметь доступ к этому списку")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Button("Создать список") {
                    if !listTitle.isEmpty {
                        onCreateList(listTitle, isSharedList)
                        dismiss()
                    }
                }
                .disabled(listTitle.isEmpty)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(listTitle.isEmpty ? Color.gray : Color.button)
                )
                .foregroundColor(.white)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 20)
            .background(Color.main)
            .navigationTitle("Новый список")
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
    CreateListModal(onCreateList: { title, isShared in
        print("Создаем: \(title), совместный: \(isShared)")
    })
}
