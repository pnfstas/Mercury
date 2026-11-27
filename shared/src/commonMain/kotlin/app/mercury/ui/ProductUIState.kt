package app.mercury.ui

import androidx.room.Ignore
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity

data class ProductUIState (
    //val product : ProductEntity,
	val id : Int = 0,
	val sku : String = "",
	val title : String = "",
	val descr : String = "",
	val elite : Boolean = false,
	val portion : Float = 0f,
	val unit : String = "",
	val single : Boolean = false,
	val price : Float = 0f,
	val oldPrice : Float = 0f,
	val quantity : Float = 0f,
	val image : String = "",
	val url : String = "",
    val quantityInStock : Float = 0f,
    val enteredQuantity : Float = 0f,
) {
    val inStock : Boolean
        get() = quantityInStock > 0
	val priceDescr : String
		get() {
			var price_descr : String = "$price р."
			if(portion > 0f && !unit.isEmpty()) {
				price_descr += " / $portion $unit"
			}
			return price_descr
		}
	fun toShoppingCartUIState() : ShoppingCartUIState {
		return ShoppingCartUIState(
			productId = id,
			quantity = enteredQuantity,
			amount = enteredQuantity * price
		)
	}
	fun toShoppingCartEntity(currentQuantity : Float = 0f) : ShoppingCartEntity {
		return ShoppingCartEntity(
			productId = id,
			quantity = currentQuantity + enteredQuantity,
			amount = (currentQuantity + enteredQuantity) * price
		)
	}
}
