//
//  ProductEntity.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.entities

data class ProductEntity(
	val picture : String,
	val name : String,
	val description : String,
	val price : Float,
	val hyperlink : String
)