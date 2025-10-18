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
                    if let viewModel = viewModel {
                        if viewModel.lists.isEmpty {
                            Text("Создайте свой первый список")
                                .font(Font.custom("villula-regular", size: 25))
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(viewModel.lists) { list in
                                NavigationLink(destination: OpenList(list: list)) {
                                    ListIcon(list: list)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                }
                .padding()
                
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
