package app.mercury.data.local.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ShoppingCartDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOne(vararg shoppingCartEntity : ShoppingCartEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(shoppingCartEntities : List<ShoppingCartEntity>): List<Long>

    @Delete
    suspend fun delete(shoppingCartEntity : ShoppingCartEntity)

    @Query("SELECT * FROM shopping_cart")
    fun getAll() : Flow<List<ShoppingCartEntity>>

	@Query("SELECT * FROM shopping_cart")
	fun getOne(productId : Int) : Flow<List<ShoppingCartEntity>>

    @Query("UPDATE shopping_cart SET quantity = :quantity WHERE productId = :productId")
    suspend fun updateQuantity(productId : Int, quantity : Float)

	@Query("""
		   UPDATE shopping_cart
		   SET quantity = shopping_cart.quantity +
			CASE products.portion > 0
				THEN products.portion
			ELSE 1.0
			END *
			CASE :decrease
				THEN -1
			ELSE 1
			END
		   FROM products
		   WHERE
			shopping_cart.productId = products.id
			shopping_cart.productId = :productId
		   """)
	suspend fun stepQuantity(productId : Int, decrease: Boolean = false)
}
