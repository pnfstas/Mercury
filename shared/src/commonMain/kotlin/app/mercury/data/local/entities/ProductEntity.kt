//
//  ProductEntity.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.entities

import androidx.room.Entity
import androidx.room.Ignore
import androidx.room.PrimaryKey
import kotlinx.serialization.Serializable
import app.mercury.ui.ProductUIState

@Serializable
@Entity(tableName = "products")
data class ProductEntity(
	@PrimaryKey(autoGenerate = true) val id : Int = 0,
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
	val url : String = ""
) {
	
	@get:Ignore
	val inStock : Boolean
		get() = quantity > 0
	@get:Ignore
	val priceDescr : String
		get() {
			var price_descr : String = "$price р."
			if(portion > 0 && !unit.isEmpty()) {
				price_descr += " / $portion $unit"
			}
			return price_descr
		}
	fun toProductUIState(enteredQuantity : Float? = null, quantityInStock : Float = 0f) : ProductUIState {
		return ProductUIState(
			id = id,
			sku = sku,
			title = title,
			descr = descr,
			elite = elite,
			portion = if(portion > 0) portion else 1f,
			unit = unit,
			single = single,
			quantity = quantity,
			price = price,
			oldPrice = oldPrice,
			image = image,
			url = url,
			quantityInStock = if(quantityInStock > 0) quantityInStock else quantity,
			/*
			enteredQuantity = enteredQuantity?.let {
				if(it > 0) it else null
			} ?: 0f
			*/
			enteredQuantity = enteredQuantity?.takeIf { it > 0f } ?: 0f
		)
	}
}
