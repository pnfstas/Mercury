package app.mercury.data.local.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import app.mercury.data.local.entities.OrderEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface OrdersDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOne(vararg orderEntity : OrderEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(orderEntities : List<OrderEntity>): List<Long>

    @Delete
    suspend fun delete(orderEntity : OrderEntity)

    @Query("SELECT * FROM orders")
    fun getAll() : Flow<List<OrderEntity>>

    @Query("UPDATE orders SET quantity = :quantity WHERE id = :id")
    suspend fun updateQuantity(id : Int, quantity : Float)
}