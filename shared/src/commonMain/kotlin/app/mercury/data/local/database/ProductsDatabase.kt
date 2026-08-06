//
//  ProductsDatabase.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.database

import androidx.room.Database
import androidx.room.RoomDatabase
import app.mercury.data.local.entities.ProductEntity

@Database(entities = [ProductEntity::class], version = 1, exportSchema = false)
abstract class ProductsDatabase : RoomDatabase() {
	abstract fun productsDao(): ProductsDao
}

expect fun getDatabaseBuilder(): RoomDatabase.Builder<ProductsDatabase>
