import SwiftUI
import shared

@Observable
final class ProductsViewModel {
    var products : [ProductEntity] = []
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        let productsInteractor : ProductsInteractor = koinHelper.getProductsInteractor()
        Task {
            for await productEntities in productsInteractor.products {
                await MainActor.run {
                    products = productEntities
                }
            }
        }
    }
    fun updateAmountInOrder(product: ProductEntity, amount : Float) {
        Task {
            do {
                await productsInteractor.updateAmountInOrder(id: product.id, amount: amount)
            }
            catch {
                println("Не удалось обновить количество для товара \(product.name)")
            }
        }
    }
    fun stepAmountInOrder(product: ProductEntity, decrease: Bool = false) {
        val step : Float = product.portion > 0 ? product.portion : 1
        if decrease {
            step *= -1
        }
        val newAmountInOrder = product.amountInOrder + step
        if newAmountInOrder >= 0 && newAmountInOrder <= product.quantity {
            updateAmountInOrder(product: product, amount: newAmountInOrder)
        }
    }
    fun increaseAmountInOrder(product: ProductEntity) {
        stepAmountInOrder(product: product)
    }
    fun decreaseAmountInOrder(product: ProductEntity) {
        stepAmountInOrder(product: product, true)
    }
    fun bindAmountInOrder(product: ProductEntity) -> Binding<Float> {
        return Binding(
            get: {
                product.amountInOrder
            }
            set: { newValue in
                self.updateAmountInOrder(product: product, amount: newValue)
            }
        )
    }
}
