//
//  ProductsDao.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ProductsDao {
	@Insert(onConflict = OnConflictStrategy.REPLACE)
	suspend fun insertOne(productEntity : ProductEntity) : Long

	@Insert(onConflict = OnConflictStrategy.REPLACE)
	suspend fun insertAll(productEntities : List<ProductEntity>): List<Long>

	@Delete
	suspend fun delete(productEntity : ProductEntity)

	@Query("SELECT * FROM products WHERE id = :id LIMIT 1")
	suspend fun getOne(id : Int) : ProductEntity?

	@Query("SELECT * FROM products ORDER BY elite DESC")
	fun getAll() : Flow<List<ProductEntity>>
}
