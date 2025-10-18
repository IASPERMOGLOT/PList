 
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateModal = false
    @State private var viewModel: ListViewModel?
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    
                    NavigationLink(destination: UserProfile()) {
                        Text("Настройки")
                            .padding()
                            .font(Font.custom("villula-regular",size: 20))
                            .foregroundColor(Color.black)
                    }
                }
                .padding(.horizontal)
                
                VStack {
                    NavigationLink(destination: OpenList()) {
                        ListIcon()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                ZStack {
                    Button(action: {
                        showingCreateModal = true
                    }) {
                        Text("Новый список")
                            .padding()
                            .font(Font.custom("villula-regular",size: 20))
                            .foregroundColor(Color.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.button)
                )
                .padding()
            }
        }
        .background(Color.main)
        .sheet(isPresented: $showingCreateModal) {
            CreateListModal(onCreateList: { title, isShared in
                viewModel?.createList(title: title, isShared: isShared)
            })
        }
        .onAppear {
            // Инициализируем ViewModel при появлении
            if viewModel == nil {
                viewModel = ListViewModel(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    NavigationView {
        ContentView()
    }
    .modelContainer(for: [List.self, Product.self, User.self])
}
