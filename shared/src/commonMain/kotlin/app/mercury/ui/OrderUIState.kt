package app.mercury.ui

import app.mercury.data.local.entities.ContactType
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.OrderItemWithDetails
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
	companion object {
		operator fun invoke(items : List<OrderItemWithDetails>) : OrderUIState? {
			val orderItem : OrderItemWithDetails? = items.firstOrNull { it.order.id > 0 && it.product.id > 0 }
			return orderItem?.let {
				OrderUIState(
					id = it.order.id,
					amount = it.order.amount,
					clientName = it.order.clientName,
					clientContacts = it.order.clientContacts,
					creationDate = it.order.creationDate,
					completionDate = it.order.completionDate,
					status = it.order.status,
					items = items.map { it.toOrderItemUIState() }
				)
			}
		}
	}
	constructor() : this(
		id = 0,
		amount = 0f,
		clientName = "",
		clientContacts = mapOf(),
		creationDate = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
		completionDate = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
		status = OrderStatus.None,
		items = emptyList()
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
			"items" -> items
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
		status : OrderStatus = this.status,
		items : List<OrderItemUIState> = this.items) : OrderUIState {
		return this.copy(
			id = id,
			amount = amount,
			clientName = clientName,
			clientContacts = clientContacts,
			creationDate = creationDate,
			completionDate = completionDate,
			status = status,
			items = items)
	}
	fun addItem(item : OrderItemUIState) : OrderUIState {
		return this.copy(items = items + item)
	}
	fun removeItem(item : OrderItemUIState) : OrderUIState {
		return this.copy(items = items.filterNot { it.orderId == item.orderId && it.productId == item.productId })
	}
}
