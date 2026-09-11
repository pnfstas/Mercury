package app.mercury.data.local.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.ForeignKey.Companion.CASCADE
import androidx.room.Index
import androidx.room.PrimaryKey
import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable

enum class OrderState {
    None,
    Created,
    Assembled,
    InTransit,
    IsReady,
    Completed
}

@Serializable
@Entity(
    tableName = "orders",
    foreignKeys = [
        ForeignKey(
            entity = ProductEntity::class,
            parentColumns = ["id"],
            childColumns = ["productId"],
            onDelete = CASCADE,
            onUpdate = CASCADE
        )
    ],
	indices = [Index(value = ["productId"])]
)
data class OrderEntity (
    @PrimaryKey(autoGenerate = true)
    val id : Int = 0,
    val productId : Int,
    val quantity : Float = 0f,
    val amount : Float = 0f,
    val creationDate : LocalDateTime,
    val completionDate : LocalDateTime,
    val state : OrderState = OrderState.None
)
