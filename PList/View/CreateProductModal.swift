// CreateProductModal.swift
import SwiftUI

struct CreateProductModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var productTitle: String = ""
    @State private var productDescription: String = ""
    @State private var expirationDays: Int = 7
    @State private var selectedImage: String = "cart"
    
    // функция для правильного написания "дня"
    private func getDayAddition(_ num: Int) -> String {
            let preLastDigit = num % 100 / 10
            
            if preLastDigit == 1 {
                return "дней"
            }
            
            switch num % 10 {
            case 1:
                return "день"
            case 2, 3, 4:
                return "дня"
            default:
                return "дней"
            }
        }
    
    let productImages = ["carrot.fill", "fish.fill","birthday.cake.fill", ""]
    var onAddProduct: (String, String, String, Int) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Название продукта
                    VStack(alignment: .leading) {
                        Text("Название продукта")
                            .font(Font.custom("villula-regular", size: 16))
                            .foregroundColor(.black)
                        
                        TextField("Введите название", text: $productTitle)
                            .font(Font.custom("villula-regular", size: 15))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 2)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Описание продукта
                    VStack(alignment: .leading) {
                        Text("Описание (необязательно)")
                            .font(Font.custom("villula-regular", size: 16))
                            .foregroundColor(.black)
                        
                        TextField("Описание, количество...", text: $productDescription)
                            .font(Font.custom("villula-regular", size: 15))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 2)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Срок годности
                    VStack(alignment: .leading) {
                        Text("Срок годности")
                            .font(Font.custom("villula-regular", size: 16))
                            .foregroundColor(.black)
                        
                        HStack {
                            Text("\(expirationDays) \(getDayAddition(expirationDays))")
                                .font(Font.custom("villula-regular", size: 15))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Stepper("", value: $expirationDays, in: 1...365)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(radius: 2)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Выбор иконки
                    VStack(alignment: .leading) {
                        Text("Иконка продукта")
                            .font(Font.custom("villula-regular", size: 16))
                            .foregroundColor(.black)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                // анимация выбора иконки
                                ForEach(productImages, id: \.self) { imageName in
                                    Button(action: {
                                        selectedImage = imageName
                                    }) {
                                        Image(systemName: imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(selectedImage == imageName ? .white : .gray)
                                            .padding(15)
                                            .background(
                                                Circle()
                                                    .fill(selectedImage == imageName ? Color.button : Color.brightGray)
                                            )
                                    }
                                }
                                // добавить кнопку добавления иконки продукта
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Кнопка добавления
                    Button("Добавить продукт") {
                        if !productTitle.isEmpty {
                            onAddProduct(productTitle, productDescription, selectedImage, expirationDays)
                            dismiss()
                        }
                    }
                    .disabled(productTitle.isEmpty)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(productTitle.isEmpty ? Color.gray : Color.button)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .background(Color.main)
            .navigationTitle("Новый продукт")
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
    CreateProductModal(onAddProduct: { title, description, image, days in
        print("Добавляем: \(title), \(description), \(image), \(days) дней")
    })
}
