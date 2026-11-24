package app.mercury.ui

import app.mercury.data.local.entities.OrderItemEntity

data class OrderItemUIState (
    val orderId : Int = 0,
    val productId : Int = 0,
    val quantity : Float = 0f,
    val amount : Float = 0f
) {
    val id : Long
		get() = (orderId.toLong() shl 32) or (productId.toLong() and 0xFFFFFFFFL)
	fun toOrderItemEntity(newOrderId : Int = 0) : OrderItemEntity {
        return OrderItemEntity (
            orderId = if(newOrderId > 0) orderId else orderId,
            productId = productId,
            quantity = quantity,
            amount = amount
        )
    }
}
