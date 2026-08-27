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
	val name : String,
	val description : String,
	val elite : Boolean,
	val price : Float,
	val minAmount : Float,
	val maxAmount : Float,
	val amountInOrder : Float,
	val picture : String,
	val url : String
) {
	val inStock : Boolean
		get() = minAmount > 0 && maxAmount >= minAmount
}
