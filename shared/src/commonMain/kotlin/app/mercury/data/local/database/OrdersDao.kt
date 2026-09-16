//
//  OrdersDao.kt
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
import androidx.room.Update
import app.mercury.data.local.entities.ContactType
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.OrderStatus
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlinx.coroutines.flow.Flow
import kotlinx.datetime.LocalDateTime

@Dao
interface OrdersDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOne(orderEntity : OrderEntity)

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertOneOrIgnore(orderEntity : OrderEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(orderEntities : List<OrderEntity>): List<Long>

    @Delete
    suspend fun delete(orderEntity : OrderEntity)

    @Query("SELECT * FROM orders")
    fun getAll() : Flow<List<OrderEntity>>

    @Query("SELECT * FROM orders WHERE productId = :productId")
    fun getOne(productId : Int) : Flow<List<OrderEntity>>

    @Query("UPDATE orders SET quantity = :quantity WHERE id = :id")
    suspend fun updateQuantity(id : Int, quantity : Float)

    @Query("UPDATE orders SET amount = :amount WHERE id = :id")
    suspend fun updateAmount(id : Int, amount : Float)

    @Query("UPDATE orders SET clientName = :clientName WHERE id = :id")
    suspend fun updateClientName(id : Int, clientName : String)

    @Query("UPDATE orders SET clientContacts = :clientContacts WHERE id = :id")
    suspend fun updateClientContacts(id : Int, clientContacts : Map<ContactType, String>)

    @Query("UPDATE orders SET creationDate = :creationDate WHERE id = :id")
    suspend fun updateCreationDate(id : Int, creationDate : LocalDateTime)

    @Query("UPDATE orders SET completionDate = :completionDate WHERE id = :id")
    suspend fun updateCompletionDate(id : Int, completionDate : LocalDateTime)

    @Query("UPDATE orders SET status = :status WHERE id = :id")
    suspend fun updateStatus(id : Int, status : OrderStatus)

    @Update
    suspend fun updateOrder(orderEntity: OrderEntity)
}