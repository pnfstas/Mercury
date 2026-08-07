package app.mercury.data.local.database

import androidx.room.Dao
import app.mercury.data.local.entities.ProductEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ProductsDao {
	fun getAll() : Flow<List<ProductEntity>>
}
