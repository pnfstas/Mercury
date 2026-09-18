//
//  MercuryShopInteractor.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.ui

import androidx.room.Ignore
import app.mercury.data.local.database.MercuryShopRepository
import app.mercury.data.local.entities.ContactType
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.OrderItemEntity
import app.mercury.data.local.entities.OrderStatus
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
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
import kotlin.Int
import kotlin.collections.set

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
    val order : OrderEntity = OrderEntity(),
    val amount : Float = 0f,
    val clientName : String = "",
    val clientContacts : Map<ContactType, String> = mapOf(),
    val creationDate : LocalDateTime,
    val completionDate : LocalDateTime,
    val status : OrderStatus = OrderStatus.None
) {
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
}

data class OrderItemUIState (
    val order : OrderEntity = OrderEntity(),
    val product : ProductEntity = ProductEntity(),
    val quantity : Float = 0f,
    val amount : Float = 0f
) {
    fun toOrderItemEntity() : OrderItemEntity {
        return OrderItemEntity (
            orderId = order.id,
            productId = product.id,
            quantity = quantity,
            amount = if(amount > 0) amount else quantity * product.price
        )
    }
}

class MercuryShopInteractor(private val mercuryShopRepository: MercuryShopRepository) {
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
    fun addToShoppingCart(shopUIState : MercuryShopUIState) {
        val shoppingCartEntity = shopUIState.toShoppingCartEntity()
        CoroutineScope(Dispatchers.IO).launch {
            mercuryShopRepository.shoppingCartDao.upsertShoppingCart(shoppingCartEntity)
        }
        enteredQuantityMap.value.remove(shopUIState.product.id)
    }
    fun stepShoppingCartQuantity(cartUIState : MercuryShopUIState, decrease: Boolean = false) {
        val productId = cartUIState.product.id
        val cartQuantity : Float = if(decrease) min(cartUIState.cartQuantity - cartUIState.portion, 0f)
            else min(cartUIState.cartQuantity + cartUIState.portion, cartUIState.quantityInStock)
        if(cartQuantity >= 0) {
            val shoppingCartEntity = ShoppingCartEntity (
                productId = cartUIState.product.id,
                quantity = cartQuantity,
                amount = cartQuantity * cartUIState.product.price
            )
            CoroutineScope(Dispatchers.IO).launch {
                mercuryShopRepository.shoppingCartDao.upsertShoppingCart(shoppingCartEntity)
            }
            if(cartQuantity > 0) {
                enteredQuantityMap.value[productId] = cartQuantity
            }
            else {
                enteredQuantityMap.value.remove(productId)
            }
        }
    }
    fun getOrderItemUIStates(orderUIState: OrderUIState) : List<OrderItemUIState> {
        return allOrderItemUIStates.value.filter { it.order.id == orderUIState.order.id }
    }
    fun createOrder(orderUIState: OrderUIState) {
        val amount : Float = cartUIStates.value.sumOf { it.cartAmount.toDouble() }.toFloat()
        if(amount > 0) {
            CoroutineScope(Dispatchers.IO).launch {
				val orderEntity : OrderEntity = orderUIState.copy(amount = amount).toOrderEntity()
                val orderId : Int = mercuryShopRepository.ordersDao.insertOne(orderEntity).toInt()
                //val newOrderEntity = orderEntity.copy(id = orderId)
                val orderItems : List<OrderItemEntity> = cartUIStates.value.map { it.toOrderItemEntity(orderId = orderId) }
                mercuryShopRepository.orderItemsDao.insertAll(orderItems)
            }
        }
    }
    fun updateOrderStatus(orderUIState: OrderUIState) {
        CoroutineScope(Dispatchers.IO).launch {
			val orderEntity : OrderEntity = orderUIState.toOrderEntity()
            mercuryShopRepository.ordersDao.updateStatus(orderEntity.id, orderEntity.status)
        }
    }
}
