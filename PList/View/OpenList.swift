import SwiftUI

struct OpenList: View {
    var list: List
    
    var body: some View {
        ZStack (alignment: .bottom) {
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        NavigationLink(destination: ListSetting(list: list)) {
                            Text("править")
                                .padding()
                                .font(Font.custom("villula-regular",size: 20))
                                .foregroundColor(Color.black)
                        }
                    }
                    
                    ListIcon(list: list, iconWidth: 380, iconHeight: 170)
                    
                    Divider()
                        .overlay(Color.main)
                        .frame(height: 15)
                    
                    // Отображаем продукты списка
                    VStack (spacing: -3) {
                        ForEach(list.products) { product in
                            ProductRow(product: product)
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
            
            // Шторка поиска
            VStack {
                Capsule()
                    .fill(Color.brightGray)
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, -20)
                    
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.brightGray)
                            .frame(width: 300, height: 50)
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14)
                            
                            Text("Мне нужно ...")
                        }
                        .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.green)
                }
                .padding(20)
            }
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(radius: 5)
                    .offset(y: 50)
                    .frame(height: 200)
            )
            .ignoresSafeArea()
        }
        .background(Color.main.ignoresSafeArea())
        .navigationTitle(list.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let sampleList = List(title: "Мой список", productCount: 3)
    return NavigationView {
        OpenList(list: sampleList)
    }
}
