//
//  ProductEntity.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.entities

import androidx.room.Entity
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
	val price : Float = 0f,
	val oldPrice : Float = 0f,
	val quantity : Float = 0f,
	val amountInOrder : Float = 0f,
	val image : String = "",
	val url : String = ""
) {
	val inStock : Boolean
		get() = quantity > 0
}
