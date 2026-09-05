import SwiftUI
import shared

@Observable
final class ProductsViewModel {
    private var productsInteractor : ProductsInteractor
    var products : [ProductEntity] = []
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        productsInteractor = koinHelper.getProductsInteractor()
        Task {
            for await productEntities in productsInteractor.products {
                await MainActor.run {
                    products = productEntities
                }
            }
        }
    }
    func updateAmountInOrder(product: ProductEntity, amount : Float) {
        Task {
            do {
                try await productsInteractor.updateAmountInOrder(id: product.id, amount: amount)
            }
            catch {
                print("Не удалось обновить количество для товара \(product.title)")
            }
        }
    }
    func stepAmountInOrder(product: ProductEntity, decrease: Bool = false) {
        var step : Float = product.portion > 0 ? product.portion : 1
        if decrease {
            step *= -1
        }
        var newAmountInOrder = product.amountInOrder + step
        if newAmountInOrder >= 0 && newAmountInOrder <= product.quantity {
            updateAmountInOrder(product: product, amount: newAmountInOrder)
        }
    }
    func increaseAmountInOrder(product: ProductEntity) {
        stepAmountInOrder(product: product)
    }
    func decreaseAmountInOrder(product: ProductEntity) {
        stepAmountInOrder(product: product, decrease: true)
    }
    func bindAmountInOrder(product: ProductEntity) -> Binding<Float> {
        return Binding(
            get: {
                product.amountInOrder
            },
            set: { newValue in
                self.updateAmountInOrder(product: product, amount: newValue)
            }
        )
    }
    func addToShoppingCart(product: ProductEntity) {
        
    }
}
