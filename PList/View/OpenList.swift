import SwiftUI
import SwiftData

struct OpenList: View {
    var list: List
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddProductModal = false
    
    var body: some View {
        ZStack (alignment: .bottom) {
            ScrollView {
                VStack {
                    ListIcon(list: list, iconWidth: 380, iconHeight: 170)
                    
                    Divider()
                        .overlay(Color.main)
                        .frame(height: 15)
                    
                    // Отображаем продукты списка
                    VStack (spacing: 10) {
                        ForEach(list.products) { product in
                            ProductRow(product: product)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteProduct(product)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteProduct(product)
                                    } label: {
                                        Label("Удалить продукт", systemImage: "trash")
                                    }
                                }
                        }
                        
                        if list.products.isEmpty {
                            Text("Список пуст")
                                .font(Font.custom("villula-regular", size: 16))
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    showingAddProductModal = true
                }) {
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.green)
                }
            }
            .padding(20)
        }
        .background(Color.main.ignoresSafeArea())
        .navigationTitle(list.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddProductModal) {
            CreateProductModal { title, description, image, days in
                addProduct(title: title, description: description, image: image, expirationDays: days)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        deleteEntireList()
                    } label: {
                        Label("Удалить весь список", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    private func addProduct(title: String, description: String, image: String, expirationDays: Int) {
        list.addProduct(
            title: title,
            content: description,
            image: image,
            expirationDate: expirationDays
        )
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка при сохранении продукта: \(error)")
        }
    }
    
    private func deleteProduct(_ product: Product) {
        list.removeProduct(product)
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка при удалении продукта: \(error)")
        }
    }
    
    private func deleteEntireList() {
        list.delete(context: modelContext)
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка при удалении списка: \(error)")
        }
    }
}

#Preview {
    OpenList(list: List(title: "Тестовый список", productCount: 2, isShared: false))
}
