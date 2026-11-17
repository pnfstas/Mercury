package app.mercury.ui

import androidx.room.Ignore
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity

data class ProductUIState (
    val product : ProductEntity,
    val portion : Float = 0f,
    val quantityInStock : Float = 0f,
    val enteredQuantity : Float = 0f
) {
    @get:Ignore
    val inStock : Boolean
        get() = quantityInStock > 0
    fun toShoppingCartEntity() : ShoppingCartEntity {
        return ShoppingCartEntity(
            productId = product.id,
            quantity = enteredQuantity,
            amount = enteredQuantity * product.price
        )
    }
}
