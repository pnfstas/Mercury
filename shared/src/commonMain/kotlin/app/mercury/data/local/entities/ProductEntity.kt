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
	val amountInOrder : Float = 0f,
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
}
