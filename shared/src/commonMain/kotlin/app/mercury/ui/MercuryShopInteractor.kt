//
//  MercuryShopInteractor.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import app.mercury.data.local.database.MercuryShopRepository
import app.mercury.data.local.entities.ContactType
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.OrderItemEntity
import app.mercury.data.local.entities.OrderStatus
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
import kotlin.time.Clock

class MercuryShopInteractor(private val mercuryShopRepository: MercuryShopRepository) : ViewModel() {
	init {
		viewModelScope.launch {
			mercuryShopRepository.updateProducts()
		}
	}
	val enteredQuantityMap = MutableStateFlow<MutableMap<Int, Float>>(mutableMapOf())
	val productUIStates : StateFlow<Map<Int, ProductUIState>> = combine(
		mercuryShopRepository.productsDao.getAll(),
		mercuryShopRepository.shoppingCartDao.getAll(),
		mercuryShopRepository.orderItemsDao.getAll(),
		enteredQuantityMap
	) {
		products, shoppingCartItems, orderItems, enteredQuantities ->
		products.associate { product ->
			val enteredQuantity : Float? = enteredQuantities[product.id]
			val cartQuantity : Float = shoppingCartItems.filter { it.productId == product.id }.sumOf { it.quantity.toDouble() }.toFloat()
			var orderedQuantity : Float = orderItems.filter { it.productId == product.id }.sumOf { it.quantity.toDouble() }.toFloat()
			val quantityInStock : Float = product.quantity - orderedQuantity - cartQuantity
			product.id to
			product.toProductUIState(enteredQuantity = enteredQuantity, quantityInStock = quantityInStock)
		}
	}
	.onEach { println("productUIStates.size: ${it.size}") }
	.stateIn(
		mercuryShopRepository.coroutineScope,
		started = SharingStarted.WhileSubscribed(5000),
		initialValue = emptyMap())
    val cartUIStates = mercuryShopRepository.shoppingCartDao.getAll().map { list ->
        list.map { it.toShoppingCartUIState() }
    }
    .onEach { println("cartUIStates.size: ${it.size}") }
    .stateIn(
        mercuryShopRepository.coroutineScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList())
    /*
	val orderUIStates = mercuryShopRepository.ordersDao.getAll().map { list ->
        list.map { it.toOrderUIState() }
    }
    .onEach { println("orderUIStates.size: ${it.size}") }
	.stateIn(
		mercuryShopRepository.coroutineScope,
		started = SharingStarted.WhileSubscribed(5000),
		initialValue = emptyList())
	*/
    val orderUIStates = mercuryShopRepository.orderItemsDao.getAllWithDetails().map { list ->
        list.map { OrderItemUIState(items = it) }
    }
    .onEach { println("orderUIStates.size: ${it.size}") }
    .stateIn(
        mercuryShopRepository.coroutineScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList())
	fun updateEnteredQuantity(productId : Int, quantity: Float) {
		enteredQuantityMap.value[productId] = max(quantity, 0f)
	}
	fun stepEnteredQuantity(productUIState : ProductUIState, decrease: Boolean = false) {
        val productId = productUIState.id
        val portion : Float = productUIState.portion
        var enteredQuantity : Float = enteredQuantityMap.value[productId] ?: 0f
        if(decrease)
            enteredQuantityMap.value[productId] = min(enteredQuantity - portion, 0f)
        else {
            val quantityInStock: Float = productUIState.quantityInStock
            enteredQuantityMap.value[productId] = min(enteredQuantity + portion, quantityInStock)
        }
	}
    suspend fun addToShoppingCart(productUIState : ProductUIState) {
        val shoppingCartEntity = productUIState.toShoppingCartEntity()
        mercuryShopRepository.shoppingCartDao.upsertShoppingCart(shoppingCartEntity)
        enteredQuantityMap.value.remove(shoppingCartEntity.productId)
    }
	suspend fun clearShoppingCart() : Int {
		return mercuryShopRepository.shoppingCartDao.deleteAll()
	}
    suspend fun stepShoppingCartQuantity(cartUIState : ShoppingCartUIState, decrease: Boolean = false) {
        val productId = cartUIState.productId
        val productUIState : ProductUIState? = productUIStates.value[productId]
        if(productUIState != null) {
            val cartQuantity: Float =
                if (decrease) min(cartUIState.quantity - productUIState.portion, 0f)
                else min(cartUIState.quantity + productUIState.portion, productUIState.quantityInStock)
            if (cartQuantity >= 0) {
                val shoppingCartEntity = ShoppingCartEntity(
                    productId = cartUIState.productId,
                    quantity = cartQuantity,
                    amount = cartQuantity * productUIState.price
                )
                mercuryShopRepository.shoppingCartDao.upsertShoppingCart(shoppingCartEntity)
                if (cartQuantity > 0) {
                    enteredQuantityMap.value[productId] = cartQuantity
                } else {
                    enteredQuantityMap.value.remove(productId)
                }
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
    suspend fun createOrder(): OrderUIState? {
        var orderUIState: OrderUIState? = null
        val amount: Float = cartUIStates.value.sumOf { it.amount.toDouble() }.toFloat()
		println("Create order, amount = $amount")
        if (amount > 0) {
			orderUIState = OrderUIState(
                creationDate = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
                completionDate = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
                amount = amount,
                status = OrderStatus.Created,
				items = cartUIStates.value.map { it.toOrderItemUIState() }
            )
        }
        return orderUIState
    }
	suspend fun saveOrder(orderUIState: OrderUIState?) : OrderUIState? {
        return orderUIState?.let {
			val orderEntity : OrderEntity = orderUIState.toOrderEntity()
			val orderId : Int = mercuryShopRepository.ordersDao.upsertOrder(orderEntity).toInt()
            val newOrderUIState : OrderUIState? = mercuryShopRepository.ordersDao.getOne(id = orderId)?.toOrderUIState(it.items)
            newOrderUIState?.let {
                val orderItems : List<OrderItemEntity> = it.items.map { it.toOrderItemEntity(orderId) }
                mercuryShopRepository.orderItemsDao.upsertAll(orderItems)
                it
            }
		}
	}
	suspend fun cancelOrder(orderUIState: OrderUIState?) : Int {
		//return orderUIState?.let {
		val count : Int = orderUIState?.let {
			val count : Int = mercuryShopRepository.ordersDao.cancelOrder(id = it.id)
			count
		} ?: 0
		return count
	}
	suspend fun deleteOrder(orderUIState: OrderUIState?) : Int {
		return orderUIState?.let {
			mercuryShopRepository.ordersDao.deleteById(id = it.id)
		} ?: 0
	}
	suspend fun deleteAllOrders() : Int {
		return mercuryShopRepository.ordersDao.deleteAll()
	}
    suspend fun updateOrderProperty(
		id : Int,
		amount : Float = 0f,
		clientName : String = "",
		clientContacts : Map<ContactType, String> = mapOf(),
		creationDate : LocalDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
		completionDate : LocalDateTime = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault()),
		status : OrderStatus = OrderStatus.None) {
        val orderEntity : OrderEntity? = mercuryShopRepository.ordersDao.getOne(id = id)
        if(orderEntity != null) {
            val newOrderEntity = orderEntity.copy(
                id = id,
                amount = amount,
                clientName = clientName,
                clientContacts = clientContacts,
                creationDate = creationDate,
                completionDate = completionDate,
                status = status)
            mercuryShopRepository.ordersDao.upsertOrder(orderEntity = newOrderEntity)
        }
    }
}
