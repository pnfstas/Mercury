package app.mercury.ui

import app.mercury.data.local.entities.ContactType
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.OrderStatus
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import kotlin.time.Clock

data class OrderUIState (
    val id : Int = 0,
    val amount : Float = 0f,
    val clientName : String = "",
    val clientContacts : Map<ContactType, String> = mapOf(),
    val creationDate : LocalDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
    val completionDate : LocalDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
    val status : OrderStatus = OrderStatus.None,
    val items : List<OrderItemUIState> = emptyList()
) {
    constructor() : this(
        id = 0,
        amount = 0f,
        clientName = "",
        clientContacts = mapOf(),
        creationDate = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
        completionDate = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
        status = OrderStatus.None
    )
    fun toOrderEntity() : OrderEntity {
        return OrderEntity(
            amount = this.amount,
            clientName = this.clientName,
            clientContacts = this.clientContacts,
            creationDate = this.creationDate,
            completionDate = this.completionDate,
            status = this.status
        )
    }
    fun getPropertyValue(propertyName : String) : Any? {
        return when(propertyName) {
            "amount" -> amount
            "clientName" -> clientName
            "clientContacts" -> clientContacts
            "creationDate" -> creationDate
            "completionDate" -> completionDate
            "status" -> status
            else -> null
        }
    }
    fun copyAndInit(
        id : Int = this.id,
        amount : Float = this.amount,
        clientName : String = this.clientName,
        clientContacts : Map<ContactType, String> = this.clientContacts,
        creationDate : LocalDateTime = this.creationDate,
        completionDate : LocalDateTime = this.completionDate,
        status : OrderStatus = this.status) : OrderUIState {
        return this.copy(
            id = id,
            amount = amount,
            clientName = clientName,
            clientContacts = clientContacts,
            creationDate = creationDate,
            completionDate = completionDate,
            status = status)
    }
}