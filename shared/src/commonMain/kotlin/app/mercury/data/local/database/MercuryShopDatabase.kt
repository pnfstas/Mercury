//
//  MercuryShopDatabase.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.database

import androidx.room.ConstructedBy
import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.RoomDatabaseConstructor
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import app.mercury.data.local.entities.OrderEntity

@Database(entities = [ProductEntity::class, ShoppingCartEntity::class, OrderEntity::class], version = 6, exportSchema = false)
@ConstructedBy(MercuryShopDatabaseConstructor::class)
abstract class MercuryShopDatabase : RoomDatabase() {
	abstract fun productsDao(): ProductsDao
	abstract fun shoppingCartDao(): ShoppingCartDao
	abstract fun ordersDao(): OrdersDao
}

@Suppress("NO_ACTUAL_FOR_EXPECT")
expect object MercuryShopDatabaseConstructor : RoomDatabaseConstructor<MercuryShopDatabase> {
	override fun initialize(): MercuryShopDatabase
}
expect fun getDatabaseBuilder(): RoomDatabase.Builder<MercuryShopDatabase>
