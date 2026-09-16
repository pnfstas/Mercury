//
//  OrderEntity.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.ForeignKey.Companion.CASCADE
import androidx.room.Index
import androidx.room.PrimaryKey
import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable

@Serializable
enum class OrderStatus {
    None,
    Created,
    Assembled,
    InTransit,
    IsReady,
    Completed
}

@Serializable
enum class ContactType {
    None,
    Phone,
    EMail,
    MAX
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
    val clientName : String = "",
    val clientContacts : Map<ContactType, String> = mapOf(),
    val creationDate : LocalDateTime,
    val completionDate : LocalDateTime,
    val status : OrderStatus = OrderStatus.None
)
