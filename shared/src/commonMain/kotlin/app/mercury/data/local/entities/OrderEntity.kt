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
enum class OrderStatus(val label : String) {
    None("None"),
    Created("Created"),
    Assembled("Assembled"),
    InTransit("In transit"),
    IsReady("Is ready"),
    Completed("Completed");
	companion object {
		fun fromLabel(label : String) : OrderStatus {
			return entries.firstOrNull { it.label.equals(label) } ?: None
		}
	}
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
            id = id,
            amount = amount,
            clientName = clientName,
            clientContacts = clientContacts,
            creationDate = creationDate,
            completionDate = completionDate,
            status = status
        )
    }
}
