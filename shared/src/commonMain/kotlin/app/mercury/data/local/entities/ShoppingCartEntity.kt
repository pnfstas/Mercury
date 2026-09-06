package app.mercury.data.local.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.ForeignKey.Companion.CASCADE
import androidx.room.PrimaryKey
import kotlinx.serialization.Serializable

@Serializable
@Entity(
    tableName = "shopping_cart",
    foreignKeys = [
        ForeignKey(
            entity = ProductEntity::class,
            parentColumns = ["id"],
            childColumns = ["productId"],
            onDelete = CASCADE,
            onUpdate = CASCADE
        )
    ])
data class ShoppingCartEntity (
    @PrimaryKey
    val productId : Int,
    val quantity : Float = 0f,
    val amount : Float = 0f
)