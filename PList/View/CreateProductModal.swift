import SwiftUI

struct CreateProductModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var productTitle: String = ""
    @State private var productDescription: String = ""
    @State private var expirationDays: Int = 7
    @State private var selectedImage: String = "cart"
    
    var list: ShoppingList? // Делаем опциональным, чтобы работало и без списка
    var onAddProduct: (String, String, String, Int) -> Void
    
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
    
    let productImages = ["carrot.fill", "fish.fill", "birthday.cake.fill", "leaf.fill", "cart.fill", "takeoutbag.and.cup.and.straw.fill"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Заголовок с иконкой
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.button)
                            
                            Text("Новый продукт")
                                .font(Font.custom("villula-regular", size: 24))
                                .foregroundColor(.primary)
                            
                            if let list = list, list.isShared {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    Text("Совместный список")
                                        .font(Font.custom("villula-regular", size: 14))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(.top, 10)
                        
                        // Название продукта
                        InputField(
                            title: "Название продукта",
                            placeholder: "Введите название",
                            text: $productTitle,
                            icon: "tag.fill"
                        )
                        
                        // Описание продукта
                        InputField(
                            title: "Описание (необязательно)",
                            placeholder: "Описание, количество...",
                            text: $productDescription,
                            icon: "text.alignleft"
                        )
                        
                        // Срок годности
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.button)
                                
                                Text("Срок годности")
                                    .font(Font.custom("villula-regular", size: 16))
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("\(expirationDays) \(getDayAddition(expirationDays))")
                                    .font(Font.custom("villula-regular", size: 16))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Stepper("", value: $expirationDays, in: 1...365)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        .padding(.horizontal)
                        
                        // Выбор иконки
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "square.grid.2x2")
                                    .foregroundColor(.button)
                                
                                Text("Иконка продукта")
                                    .font(Font.custom("villula-regular", size: 16))
                                    .foregroundColor(.primary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(productImages, id: \.self) { imageName in
                                        IconButton(
                                            imageName: imageName,
                                            isSelected: selectedImage == imageName,
                                            action: { selectedImage = imageName }
                                        )
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Кнопка добавления
                        Button("Добавить продукт") {
                            if !productTitle.isEmpty {
                                onAddProduct(productTitle, productDescription, selectedImage, expirationDays)
                                dismiss()
                            }
                        }
                        .disabled(productTitle.isEmpty)
                        .font(Font.custom("villula-regular", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    productTitle.isEmpty ? Color.gray : Color.button,
                                    productTitle.isEmpty ? Color.gray.opacity(0.8) : Color.button.opacity(0.9)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .cornerRadius(15)
                            .shadow(color: productTitle.isEmpty ? .clear : Color.button.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
            }
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

// Компонент поля ввода
struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.button)
                
                Text(title)
                    .font(Font.custom("villula-regular", size: 16))
                    .foregroundColor(.primary)
            }
            
            TextField(placeholder, text: $text)
                .font(Font.custom("villula-regular", size: 16))
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal)
    }
}

// Компонент кнопки иконки
struct IconButton: View {
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: imageName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : .button)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.button : Color.button.opacity(0.1))
                    )
                
                if isSelected {
                    Circle()
                        .fill(Color.button)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let sampleList = ShoppingList(title: "Тестовый список", isShared: true)
    
    return CreateProductModal(
        list: sampleList,
        onAddProduct: { title, description, image, days in
            print("Добавляем: \(title), \(description), \(image), \(days) дней")
        }
    )
}
