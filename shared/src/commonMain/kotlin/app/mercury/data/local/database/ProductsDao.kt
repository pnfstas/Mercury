package app.mercury.data.local.database

import androidx.room.Dao
import androidx.room.Query
import app.mercury.data.local.entities.ProductEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ProductsDao {
	@Query("SELECT * FROM ProductEntity")
	fun getAll() : Flow<List<ProductEntity>>
}
