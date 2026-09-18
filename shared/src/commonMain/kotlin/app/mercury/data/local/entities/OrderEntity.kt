package app.mercury.data.local.entities

import androidx.room.Embedded
import app.mercury.ui.OrderUIState
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import kotlinx.serialization.Serializable
import kotlin.Float
import kotlin.time.Instant

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
@Entity(tableName = "orders")
data class OrderEntity (
    @PrimaryKey(autoGenerate = true)
    val id : Int = 0,
    val amount : Float = 0f,
    val clientName : String = "",
    val clientContacts : Map<ContactType, String> = mapOf(),
    val creationDate : LocalDateTime = Instant.fromEpochMilliseconds(0).toLocalDateTime(TimeZone.currentSystemDefault()),
    val completionDate : LocalDateTime = Instant.fromEpochMilliseconds(0).toLocalDateTime(TimeZone.currentSystemDefault()),
    val status : OrderStatus = OrderStatus.None
) {
    fun toOrderUIState() : OrderUIState {
        return OrderUIState (
            order = this,
            amount = amount,
            clientName = clientName,
            clientContacts = clientContacts,
            creationDate = creationDate,
            completionDate = completionDate,
            status = status
        )
    }
}