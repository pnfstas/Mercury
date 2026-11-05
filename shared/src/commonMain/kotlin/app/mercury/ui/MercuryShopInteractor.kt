//
//  MercuryShopInteractor.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.ui

import androidx.lifecycle.ViewModel
import androidx.room.Ignore
import app.mercury.data.local.database.MercuryShopRepository
import app.mercury.data.local.entities.ContactType
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.OrderItemEntity
import app.mercury.data.local.entities.OrderStatus
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlinx.coroutines.flow.MutableStateFlow
import kotlin.math.min
import kotlin.math.max
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import kotlin.Int
import kotlin.collections.set
import kotlin.reflect.KClass
import kotlin.reflect.KFunction
import kotlin.time.Clock
import kotlin.time.Instant

data class MercuryShopUIState (
    val product : ProductEntity,
    val portion : Float = 0f,
    val quantityInStock : Float = 0f,
    val enteredQuantity : Float = 0f,
    val cartQuantity : Float = 0f,
    val orderedQuantity : Float = 0f
) {
    @get:Ignore
    val inStock : Boolean
        get() = quantityInStock > 0
    @get:Ignore
    val cartAmount : Float
        get() = cartQuantity * product.price
    fun toOrderItemEntity(orderId : Int) : OrderItemEntity {
        return OrderItemEntity(
            orderId = orderId,
            productId = product.id,
            quantity = cartQuantity,
            amount = cartAmount
        )
    }
    fun toShoppingCartEntity() : ShoppingCartEntity {
        return ShoppingCartEntity(
            productId = product.id,
            quantity = enteredQuantity,
            amount = enteredQuantity * product.price
        )
    }
}

data class OrderUIState (
    val id : Int = 0,
    val amount : Float = 0f,
    val clientName : String = "",
    val clientContacts : Map<ContactType, String> = mapOf(),
    val creationDate : LocalDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
    val completionDate : LocalDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
    val status : OrderStatus = OrderStatus.None
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
	private val reflectionHelper = ReflectionHelper()
    val amountStr : String
		get() {
			return amount.toString()
		}
	val creationDateStr : String
		get() {
			return creationDate.toString()
		}
	val completionDateStr : String
		get() {
			return completionDate.toString()
		}
	val statusDesc : String
		get() {
			return status.label
		}
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
    fun copyWith(propertyName : String, propertyValue : Any?) : OrderUIState? {
        return reflectionHelper.copyWith(instance = this, propertyName = propertyName, propertyValue = propertyValue)
    }
	fun with(
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

expect class ReflectionHelper() {
    fun <T : Any> copyWith(instance: T, propertyName: String, propertyValue: Any?) : T?
}
inline fun <reified T : Any> ReflectionHelper.copyWith(instance: T, propertyName: String, propertyValue: Any?) : T? {
    return this.copyWith(instance = instance, propertyName = propertyName, propertyValue = propertyValue);
}

data class OrderItemUIState (
    val orderId : Int = 0,
    val productId : Int = 0,
    val quantity : Float = 0f,
    val amount : Float = 0f
) {
	fun toOrderItemEntity() : OrderItemEntity {
        return OrderItemEntity (
            orderId = orderId,
            productId = productId,
            quantity = quantity,
            amount = amount
        )
    }
}

class MercuryShopInteractor(private val mercuryShopRepository: MercuryShopRepository) : ViewModel() {
    val enteredQuantityMap = MutableStateFlow<MutableMap<Int, Float>>(mutableMapOf())
	val shopUIStates : StateFlow<List<MercuryShopUIState>> = combine(
        mercuryShopRepository.productsDao.getAll(),
        mercuryShopRepository.shoppingCartDao.getAll(),
        mercuryShopRepository.orderItemsDao.getAll(),
        enteredQuantityMap
    ) {
        products, cartItems, orders, enteredQuantities ->
        products.map { product ->
            val portion : Float = if(product.portion > 0) product.portion else 1f
			val enteredQuantity : Float? = enteredQuantities[product.id]
            val cartItem : ShoppingCartEntity? = cartItems.find { it.productId == product.id }
            val orderedQuantity : Float = orders.filter { it.productId == product.id }.sumOf { it.quantity.toDouble() }.toFloat()
            MercuryShopUIState(
                product = product,
                portion = portion,
                quantityInStock = product.quantity,
                enteredQuantity  = enteredQuantity ?: if(portion <= product.quantity) portion else 0f,
                cartQuantity = cartItem?.quantity ?: 0f,
                orderedQuantity = orderedQuantity
            )
        }
    }
	.onEach { println("shopUIStates.size: ${it.size}") }
    .stateIn(
        mercuryShopRepository.coroutineScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList())
    val cartUIStates = shopUIStates.map { list ->
        list.filter { it.cartQuantity > 0 }
    }
	.onEach { println("cartUIStates.size: ${it.size}") }
    .stateIn(
        mercuryShopRepository.coroutineScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList())
    val orderUIStates = mercuryShopRepository.ordersDao.getAll().map { list ->
        list.map { it.toOrderUIState() }
    }
    .onEach { println("orderUIStates.size: ${it.size}") }
	.stateIn(
		mercuryShopRepository.coroutineScope,
		started = SharingStarted.WhileSubscribed(5000),
		initialValue = emptyList())
    val allOrderItemUIStates = mercuryShopRepository.orderItemsDao.getAllWithDetails().map { list ->
        list.map { it.toOrderItemUIState() }
    }
    .onEach { println("orderItemUIStates.size: ${it.size}") }
    .stateIn(
        mercuryShopRepository.coroutineScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList())
	fun updateEnteredQuantity(shopUIState : MercuryShopUIState, quantity: Float) {
		val productId = shopUIState.product.id
		enteredQuantityMap.value[productId] = max(quantity, 0f)
	}
	fun stepEnteredQuantity(shopUIState : MercuryShopUIState, decrease: Boolean = false) {
        val productId = shopUIState.product.id
        val portion : Float = shopUIState.portion
        var enteredQuantity : Float = enteredQuantityMap.value[productId] ?: 0f
        if(decrease)
            enteredQuantityMap.value[productId] = min(enteredQuantity - portion, 0f)
        else {
            val quantityInStock: Float = shopUIState.quantityInStock
            enteredQuantityMap.value[productId] = min(enteredQuantity + portion, quantityInStock)
        }
	}
    suspend fun addToShoppingCart(shopUIState : MercuryShopUIState) {
        val shoppingCartEntity = shopUIState.toShoppingCartEntity()
        mercuryShopRepository.shoppingCartDao.upsertShoppingCart(shoppingCartEntity)
        enteredQuantityMap.value.remove(shopUIState.product.id)
    }
    suspend fun stepShoppingCartQuantity(cartUIState : MercuryShopUIState, decrease: Boolean = false) {
        val productId = cartUIState.product.id
        val cartQuantity : Float = if(decrease) min(cartUIState.cartQuantity - cartUIState.portion, 0f)
            else min(cartUIState.cartQuantity + cartUIState.portion, cartUIState.quantityInStock)
        if(cartQuantity >= 0) {
            val shoppingCartEntity = ShoppingCartEntity (
                productId = cartUIState.product.id,
                quantity = cartQuantity,
                amount = cartQuantity * cartUIState.product.price
            )
            mercuryShopRepository.shoppingCartDao.upsertShoppingCart(shoppingCartEntity)
            if(cartQuantity > 0) {
                enteredQuantityMap.value[productId] = cartQuantity
            }
            else {
                enteredQuantityMap.value.remove(productId)
            }
        }
    }
    fun getOrderItemUIStates(orderUIState: OrderUIState) : StateFlow<List<OrderItemUIState>> {
        return mercuryShopRepository.orderItemsDao.getAllOfOrderWithDetails(orderId = orderUIState.id).map { list ->
            list.map { it.toOrderItemUIState() }
        }
        .stateIn(
            mercuryShopRepository.coroutineScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList())
    }
    suspend fun createOrder() : OrderUIState? {
		var orderUIState : OrderUIState? = null
		val amount : Float = cartUIStates.value.sumOf { it.cartAmount.toDouble() }.toFloat()
        if(amount > 0) {
            val orderUIState = OrderUIState(
                id = 0,
                creationDate = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
                completionDate = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
                amount = amount,
                status = OrderStatus.Created)
            val orderEntity : OrderEntity = orderUIState.toOrderEntity()
            val orderId : Int = mercuryShopRepository.ordersDao.insertOne(orderEntity).toInt()
            updateOrderProperty(orderUIState = orderUIState, id = orderId)
            val orderItems : List<OrderItemEntity> = cartUIStates.value.map { it.toOrderItemEntity(orderId = orderId) }
            mercuryShopRepository.orderItemsDao.insertAll(orderItems)
        }
		return orderUIState
    }
	suspend fun updateOrder(orderUIState: OrderUIState) {
        val orderEntity : OrderEntity = orderUIState.toOrderEntity()
        mercuryShopRepository.ordersDao.upsertOrder(orderEntity)
	}
    suspend fun updateOrderProperty(
		orderUIState: OrderUIState,
		id : Int = 0,
		amount : Float = 0f,
		clientName : String = "",
		clientContacts : Map<ContactType, String> = mapOf(),
		creationDate : LocalDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
		completionDate : LocalDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
		status : OrderStatus = OrderStatus.None) {
        val newOrderUIState : OrderUIState? = orderUIState.with(
			id = id,
			amount = amount,
			clientName = clientName,
			clientContacts = clientContacts,
			creationDate = creationDate,
			completionDate = completionDate,
			status = status)
        if(newOrderUIState != null) {
            val orderEntity: OrderEntity = orderUIState.toOrderEntity()
            mercuryShopRepository.ordersDao.upsertOrder(orderEntity)
        }
    }
}
