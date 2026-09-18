package app.mercury.data.local.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import androidx.room.Upsert
import app.mercury.data.local.entities.OrderItemEntity
import app.mercury.data.local.entities.OrderItemWithDetails
import kotlinx.coroutines.flow.Flow

@Dao
interface OrderItemsDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOne(orderItemEntity: OrderItemEntity) : Long

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertOneOrIgnore(orderItemEntity: OrderItemEntity) : Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(orderItemEntities : List<OrderItemEntity>): List<Long>

    @Upsert
    suspend fun upsertOrderItem(orderItemEntity: OrderItemEntity) : Long

    @Delete
    suspend fun delete(orderItemEntity: OrderItemEntity)

    @Delete
    suspend fun deleteAll(orderItemEntities : List<OrderItemEntity>) : Int

    @Query("DELETE FROM order_items WHERE orderId = :orderId")
    fun deleteAllOfOrder(orderId : Int)

    @Query("SELECT * FROM order_items")
    fun getAll() : Flow<List<OrderItemEntity>>

    @Query("SELECT * FROM order_items")
    fun getAllWithDetails() : Flow<List<OrderItemWithDetails>>

    @Query("SELECT * FROM order_items WHERE orderId = :orderId")
    fun getAllOfOrder(orderId : Int) : Flow<List<OrderItemEntity>>

    @Query("SELECT * FROM order_items WHERE orderId = :orderId")
    fun getAllOfOrderWithDetails(orderId : Int) : Flow<List<OrderItemWithDetails>>

    @Query("SELECT * FROM order_items WHERE orderId = :orderId AND productId = :productId LIMIT 1")
    fun getOne(orderId : Int, productId : Int) : Flow<OrderItemEntity>

    @Query("UPDATE order_items SET quantity = :quantity WHERE productId = :productId")
    suspend fun updateQuantity(productId : Int, quantity : Float)

    @Query("UPDATE order_items SET amount = :amount WHERE productId = :productId")
    suspend fun updateAmount(productId : Int, amount : Float)
}