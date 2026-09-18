//
//  ShoppingCartDao.kt
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
import androidx.room.Upsert
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ShoppingCartDao {
    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertOneOrIgnore(shoppingCartEntity : ShoppingCartEntity) : Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(shoppingCartEntities : List<ShoppingCartEntity>): List<Long>

    @Upsert
    suspend fun upsertShoppingCart(shoppingCartEntity : ShoppingCartEntity) : Long

    @Delete
    suspend fun delete(shoppingCartEntity : ShoppingCartEntity)

    @Query("SELECT * FROM shopping_cart")
    fun getAll() : Flow<List<ShoppingCartEntity>>

	@Query("SELECT * FROM shopping_cart WHERE productId = :productId LIMIT 1")
	suspend fun getOne(productId : Int) : ShoppingCartEntity?

    @Query("SELECT * FROM shopping_cart WHERE productId = :productId LIMIT 1")
    fun getOneFlow(productId : Int) : Flow<ShoppingCartEntity>

    @Query("UPDATE shopping_cart SET quantity = :quantity WHERE productId = :productId")
    suspend fun updateQuantity(productId : Int, quantity : Float)

	@Query("""
		   UPDATE shopping_cart
		   SET quantity = shopping_cart.quantity +
			CASE 
                WHEN (SELECT portion FROM products WHERE id = :productId) > 0
				    THEN (SELECT portion FROM products WHERE id = :productId)
                ELSE 1
            END *
			CASE 
                WHEN :decrease = 1
				    THEN -1
			    ELSE 1
			END
		   WHERE
			shopping_cart.productId = :productId
		   """)
	suspend fun stepQuantity(productId : Int, decrease: Boolean = false)
}
