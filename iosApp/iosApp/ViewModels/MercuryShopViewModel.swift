import SwiftUI
import shared

@Observable
final class MercuryShopViewModel {
    private var mercuryShopInteractor : MercuryShopInteractor
    var shopUIStates : [MercuryShopUIState] = []
    var cartUIStates : [MercuryShopUIState] = []
    var orderUIStates : [MercuryShopUIState] = []
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        mercuryShopInteractor = koinHelper.getMercuryShopInteractor()
        Task {
            for await curShopUIStates in mercuryShopInteractor.shopUIStates {
                await MainActor.run {
                    shopUIStates = curShopUIStates
                }
            }
            for await curCartUIStates in mercuryShopInteractor.cartUIStates {
                await MainActor.run {
                    cartUIStates = curCartUIStates
                }
            }
            for await curOrderUIStates in mercuryShopInteractor.orderUIStates {
                await MainActor.run {
                    orderUIStates = curOrderUIStates
                }
            }

        }
    }
    func increaseEnteredQuantity(shopUIState : MercuryShopUIState) {
        mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: false)
    }
    func decreaseEnteredQuantity(shopUIState : MercuryShopUIState) {
        mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: true)
    }
    func bindEnteredQuantity(shopUIState : MercuryShopUIState) -> Binding<Float> {
        return Binding(
            get: {
                shopUIState.enteredQuantity
            },
            set: { newValue in
                shopUIState.enteredQuantity = newValue
            }
        )
    }
    func addToShoppingCart(shopUIState : MercuryShopUIState) {
        Task {
            do {
                try await mercuryShopInteractor.addToShoppingCart(shopUIState: shopUIState)
            }
            catch {
                print("Не удалось добавить в корзину или изменить коичество для товара \(shopUIState.product.title)")
            }
        }
    }
    func increaseShoppingCartQuantity(cartUIState : MercuryShopUIState) {
        Task {
            do {
                try await mercuryShopInteractor.stepShoppingCartQuantity(shopUIState: shopUIState, decrease: false)
            }
            catch {
                print("Не удалось уменьшить коичество товара \(shopUIState.product.title) в корзине")
            }
        }
    }
    func decreaseShoppingCartQuantity(cartUIState : MercuryShopUIState) {
        Task {
            do {
                try await mercuryShopInteractor.stepShoppingCartQuantity(shopUIState: shopUIState, decrease: true)
            }
            catch {
                print("Не удалось увеличить коичество товара \(shopUIState.product.title) в корзине")
            }
        }
    }
    func bindShoppingCartQuantity(cartUIState : MercuryShopUIState) -> Binding<Float> {
        return Binding(
            get: {
                shopUIState.cartQuantity
            },
            set: { newValue in
                shopUIState.cartQuantity = newValue
            }
        )
    }

}
