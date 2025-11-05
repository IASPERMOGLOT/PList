import SwiftUI

struct ProductsListView: View {
    let unpurchasedProducts: [Product]
    let purchasedProducts: [Product]
    let isShared: Bool
    let onTogglePurchase: (Product) -> Void
    let onDeleteProduct: (Product) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if !unpurchasedProducts.isEmpty {
                    ProductSection(count: unpurchasedProducts.count, icon: "cart.fill", color: .orange) {
                        ForEach(unpurchasedProducts) { product in
                            ModernProductRow(
                                product: product,
                                onPurchase: { onTogglePurchase(product) },
                                onDelete: { onDeleteProduct(product) }
                            )
                        }
                    }
                }
                
                if !purchasedProducts.isEmpty {
                    ProductSection(count: purchasedProducts.count, icon: "checkmark.circle.fill", color: .green) {
                        ForEach(purchasedProducts) { product in
                            ModernProductRow(
                                product: product,
                                onPurchase: { onTogglePurchase(product) },
                                onDelete: { onDeleteProduct(product) }
                            )
                        }
                    }
                }
                
                if unpurchasedProducts.isEmpty && purchasedProducts.isEmpty {
                    EmptyListView(isShared: isShared)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}

struct ProductSection<Content: View>: View {
    let count: Int
    let icon: String
    let color: Color
    let content: Content
    
    init(count: Int, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.count = count
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label {
                    Text("\(count)")
                        .font(Font.custom("villula-regular", size: 18))
                } icon: {
                    Image(systemName: icon)
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
