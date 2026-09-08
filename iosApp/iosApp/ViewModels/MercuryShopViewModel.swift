import SwiftUI
import shared

@Observable
final class MercuryShopViewModel {
    private var mercuryShopInteractor : MercuryShopInteractor
    var shopUIStates : [MercuryShopUIState] = []
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        mercuryShopInteractor = koinHelper.getMercuryShopInteractor()
        Task {
            for await curShopUIStates in mercuryShopInteractor.shopUIStates {
                await MainActor.run {
                    shopUIStates = curShopUIStates
                }
            }
        }
    }
    func increaseQuantityInShoppingCart(shopUIState : MercuryShopUIState) {
        Task {
            do {
                try await mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: false)
            }
            catch {
                print("Не удалось обновить количество для товара \(shopUIState.product.title)")
            }
        }
    }
    func decreaseQuantityInShoppingCart(shopUIState : MercuryShopUIState) {
        Task {
            do {
                try await mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: true)
            }
            catch {
                print("Не удалось обновить количество для товара \(shopUIState.product.title)")
            }
        }
    }
    func bindQuantityInShoppingCart(shopUIState : MercuryShopUIState) -> Binding<Float> {
        return Binding(
            get: {
                shopUIState.enteredQuantity
            },
            set: { newValue in
                shopUIState.enteredQuantity = newValue
            }
        )
    }
    fun addToShoppingCartOrUpdateQuantity(shopUIState : MercuryShopUIState) {
        Task {
            do {
                try await mercuryShopInteractor.addToShoppingCartOrUpdateQuantity(shopUIState: shopUIState)
            }
            catch {
                print("Не удалось добавить в корзину или изменить коичество для товара \(shopUIState.product.title)")
            }
        }
    }
}
