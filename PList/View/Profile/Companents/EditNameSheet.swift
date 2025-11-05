import SwiftUI

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
