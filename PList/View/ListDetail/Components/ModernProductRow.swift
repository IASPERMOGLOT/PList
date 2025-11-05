import SwiftUI

struct ModernProductRow: View {
    let product: Product
    let onPurchase: () -> Void
    let onDelete: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            PurchaseButton(isPurchased: product.isPurchased, action: onPurchase)
            
            ProductInfoView(product: product)
            
            Spacer()
            
            ExpirationIndicator(product: product)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(product.isPurchased ? Color.gray.opacity(0.05) : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(product.isPurchased ? Color.green.opacity(0.2) : Color.gray.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .onChange(of: product.isPurchased) { oldValue, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = false
                }
            }
        }
    }
}

struct ProductInfoView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: product.image)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(product.isPurchased ? .gray : .button)
                    .frame(width: 20)
                
                Text(product.title)
                    .font(Font.custom("villula-regular", size: 17))
                    .foregroundColor(product.isPurchased ? .gray : .primary)
                    .strikethrough(product.isPurchased, color: .gray)
            }
            
            if !product.content.isEmpty {
                Text(product.content)
                    .font(Font.custom("villula-regular", size: 14))
                    .foregroundColor(product.isPurchased ? .gray.opacity(0.7) : .secondary)
                    .padding(.leading, 28)
            }
            
            if product.isPurchased {
                Text("Годен до \(formatDate(product.expirationDateValue))")
                    .font(Font.custom("villula-regular", size: 12))
                    .foregroundColor(expirationColor)
                    .padding(.leading, 28)
            }
        }
    }
    
    private var expirationColor: Color {
        if product.isExpired { return .red }
        if product.expiresToday { return .orange }
        if product.isExpiringSoon { return .orange }
        return .gray
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: date)
    }
}

struct PurchaseButton: View {
    let isPurchased: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isPurchased ? Color.green : Color.gray.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                if isPurchased {
                    Image(systemName: "checkmark")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExpirationIndicator: View {
    let product: Product
    
    var body: some View {
        VStack(spacing: 2) {
            if product.isPurchased {
                Group {
                    if product.isExpiringSoon {
                        Text("1 день!")
                    } else if product.expiresToday {
                        Text("Срок!")
                    } else if product.isExpired {
                        Text("Просрочено")
                    } else {
                        Text("\(product.daysUntilExpiration)д")
                    }
                }
                .font(Font.custom("villula-regular", size: 10))
                .foregroundColor(expirationTextColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(expirationBackgroundColor.opacity(0.2))
                .cornerRadius(6)
            } else {
                Text("\(product.expirationDate)д")
                    .font(Font.custom("villula-regular", size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var expirationTextColor: Color {
        if product.isExpired || product.expiresToday { return .red }
        if product.isExpiringSoon { return .orange }
        return .green
    }
    
    private var expirationBackgroundColor: Color {
        if product.isExpired || product.expiresToday { return .red }
        if product.isExpiringSoon { return .orange }
        return .green
    }
}
