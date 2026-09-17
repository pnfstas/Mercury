//
//  MercuryShopViewModel.swift
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
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
        Task { @MainActor in
            for await curShopUIStates in mercuryShopInteractor.shopUIStates {
                await MainActor.run {
                    shopUIStates = curShopUIStates
                }
            }
        }
        Task { @MainActor in
            for await curCartUIStates in mercuryShopInteractor.cartUIStates {
                await MainActor.run {
                    cartUIStates = curCartUIStates
                }
            }
        }
        Task { @MainActor in
            for await curOrderUIStates in mercuryShopInteractor.orderUIStates {
                await MainActor.run {
                    orderUIStates = curOrderUIStates
                }
            }
        }
    }
    func increaseEnteredQuantity(shopUIState: MercuryShopUIState) {
        mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: false)
    }
    func decreaseEnteredQuantity(shopUIState: MercuryShopUIState) {
        mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: true)
    }
    func bindEnteredQuantity(shopUIState: MercuryShopUIState) -> Binding<Float> {
        return Binding(
            get: {
                shopUIState.enteredQuantity
            },
            set: { newValue in
                self.mercuryShopInteractor.updateEnteredQuantity(shopUIState: shopUIState, quantity: newValue)
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
                self.mercuryShopInteractor.updateEnteredQuantity(shopUIState: cartUIState, quantity: newValue)
            }
        )
    }
    func createOrder(orderUIState: OrderUIState) {
        mercuryShopInteractor.createOrder(orderUIState: orderUIState)
    }
    func updateOrderStatus(orderUIState: OrderUIState) {
        mercuryShopInteractor.updateOrderStatus(orderUIState: orderUIState)
    }
}
