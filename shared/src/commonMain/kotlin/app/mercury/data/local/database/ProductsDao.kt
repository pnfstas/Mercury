package app.mercury.data.local.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import app.mercury.data.local.entities.ProductEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ProductsDao {
	@Insert(onConflict = OnConflictStrategy.REPLACE)
	suspend fun insertOne(vararg productEntity : ProductEntity)

	@Insert(onConflict = OnConflictStrategy.REPLACE)
	suspend fun insertAll(productEntities : List<ProductEntity>): List<Long>

	@Delete
	suspend fun delete(productEntity : ProductEntity)

	@Query("SELECT * FROM products ORDER BY elite DESC")
	fun getAll() : Flow<List<ProductEntity>>

	@Query("UPDATE products SET amountInOrder = :amount WHERE id = :id")
	suspend fun updateAmountInOrder(id : Int, amount : Float)
}
