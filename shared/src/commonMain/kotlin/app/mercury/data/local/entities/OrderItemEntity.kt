//
//  OrderItemEntity.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.entities

import app.mercury.ui.OrderItemUIState
import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.ForeignKey.Companion.CASCADE
import androidx.room.Index
import androidx.room.Junction
import androidx.room.Relation
import kotlinx.serialization.Serializable

@Serializable
@Entity(
    tableName = "order_items",
    primaryKeys = ["orderId", "productId"],
    foreignKeys = [
        ForeignKey(
            entity = OrderEntity::class,
            parentColumns = ["id"],
            childColumns = ["orderId"],
            onDelete = CASCADE,
            onUpdate = CASCADE
        ),
        ForeignKey(
            entity = ProductEntity::class,
            parentColumns = ["id"],
            childColumns = ["productId"],
            onDelete = CASCADE,
            onUpdate = CASCADE
        )
    ],
	indices = [Index(value = ["orderId"]), Index(value = ["productId"])]
)
data class OrderItemEntity(
    val orderId : Int,
    val productId : Int,
    val quantity : Float = 0f,
    val amount : Float = 0f
)

data class OrderItemWithDetails(
    @Embedded
    val orderItem : OrderItemEntity,
    @Relation(
        parentColumn = "orderId",
        entityColumn = "id"
    )
    val order : OrderEntity,
    @Relation(
        parentColumn = "productId",
        entityColumn = "id"
    )
    val product : ProductEntity
) {
    fun toOrderItemUIState() : OrderItemUIState {
        return OrderItemUIState(
            order = order,
            product = product,
            quantity = orderItem.quantity,
            amount = orderItem.amount
        )
    }
}
