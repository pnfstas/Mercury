import SwiftUI
import shared

@Observable
final class MercuryShopViewModel {
    private var mercuryShopInteractor : MercuryShopInteractor
    var products : [ProductUIState] = []
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        mercuryShopInteractor = koinHelper.getMercuryShopInteractor()
        Task {
            for await productUIStates in mercuryShopInteractor.products {
                await MainActor.run {
                    products = productUIStates
                }
            }
        }
    }
    func updateQuantityInShoppingCart(product: ProductEntity, quantity : Float) {
        Task {
            do {
                try await mercuryShopInteractor.updateQuantityInShoppingCart(productId: product.id, quantity: quantity)
            }
            catch {
                print("Не удалось обновить количество для товара \(product.title)")
            }
        }
    }
    func increaseQuantityInShoppingCart(product: ProductEntity) {
        Task {
            do {
                try await mercuryShopInteractor.stepQuantityInShoppingCart(productId: product.id, decrease: false)
            }
            catch {
                print("Не удалось обновить количество для товара \(product.title)")
            }
        }
    }
    func decreaseQuantityInShoppingCart(product: ProductEntity) {
        Task {
            do {
                try await mercuryShopInteractor.stepQuantityInShoppingCart(productId: product.id, decrease: true)
            }
            catch {
                print("Не удалось обновить количество для товара \(product.title)")
            }
        }
    }
    func bindQuantityInShoppingCart(product: ProductEntity) -> Binding<Float> {
        return Binding(
            get: {
                product.amountInOrder
            },
            set: { newValue in
                self.updateQuantityInShoppingCart(product: product, quantity: newValue)
            }
        )
    }
    func addToShoppingCart(product: ProductEntity) {
        
    }
}
