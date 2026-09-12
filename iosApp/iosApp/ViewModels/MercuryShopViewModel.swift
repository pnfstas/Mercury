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
        mercuryShopInteractor.addToShoppingCart(shopUIState: shopUIState)
    }
    func increaseShoppingCartQuantity(cartUIState : MercuryShopUIState) {
        mercuryShopInteractor.stepShoppingCartQuantity(cartUIState : cartUIState, decrease: false)
    }
    func decreaseShoppingCartQuantity(cartUIState : MercuryShopUIState) {
        mercuryShopInteractor.stepShoppingCartQuantity(cartUIState : cartUIState, decrease: true)
    }
    func bindShoppingCartQuantity(cartUIState : MercuryShopUIState) -> Binding<Float> {
        return Binding(
            get: {
                cartUIState.cartQuantity
            },
            set: { newValue in
                cartUIState.cartQuantity = newValue
            }
        )
    }

}
