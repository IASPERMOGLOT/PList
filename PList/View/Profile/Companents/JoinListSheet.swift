import SwiftUI

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
