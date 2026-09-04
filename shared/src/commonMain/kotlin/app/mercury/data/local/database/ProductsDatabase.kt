//
//  ProductsDatabase.kt
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

@Database(entities = [ProductEntity::class], version = 5, exportSchema = false)
@ConstructedBy(ProductsDatabaseConstructor::class)
abstract class ProductsDatabase : RoomDatabase() {
	abstract fun productsDao(): ProductsDao
}

@Suppress("NO_ACTUAL_FOR_EXPECT")
expect object ProductsDatabaseConstructor : RoomDatabaseConstructor<ProductsDatabase> {
	override fun initialize(): ProductsDatabase
}
expect fun getDatabaseBuilder(): RoomDatabase.Builder<ProductsDatabase>
