package app.mercury.ui

import app.mercury.data.local.entities.ShoppingCartEntity

data class ShoppingCartUIState (
    val productId : Int = 0,
    val quantity : Float = 0f,
    val amount : Float = 0f
) {
    fun toShoppingCartEntity() : ShoppingCartEntity {
        return ShoppingCartEntity(
            productId = productId,
            quantity = quantity,
            amount = amount
        )
    }
    fun toOrderItemUIState(orderId : Int = 0) : OrderItemUIState {
        return OrderItemUIState(
            orderId = orderId,
            productId = productId,
            quantity = quantity,
            amount = amount
        )
    }
}