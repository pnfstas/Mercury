//
//  ProductEntity.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.entities

import androidx.room.Entity
import kotlinx.serialization.Serializable

@Serializable
@Entity(tableName = "products")
data class ProductEntity(
	val name : String,
	val description : String,
	val price : Float,
	val picture : String,
	val url : String
)