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
import kotlinx.coroutines.flow.update
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
	val enteredQuantityMap = MutableStateFlow<Map<Int, Float>>(emptyMap())
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
    val orderUIStates = mercuryShopRepository.orderItemsDao.getAllWithDetails().map { list ->
        list.groupBy { it.order.id }.map { (orderId, items) -> OrderUIState(items = items) }
    }
    .onEach { println("orderUIStates.size: ${it.size}") }
    .stateIn(
        mercuryShopRepository.coroutineScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList())
	fun updateEnteredQuantity(productId : Int, quantity : Float) {
		val productUIState : ProductUIState? = productUIStates.value[productId]
		val newQuantity : Float = productUIState?.let { min(quantity, productUIState.quantityInStock) } ?: 0f
		enteredQuantityMap.update { currentMap ->
			if(newQuantity > 0) currentMap + (productId to newQuantity) else currentMap - productId
		}
	}
	fun stepEnteredQuantity(productUIState : ProductUIState, decrease: Boolean = false) {
        val productId = productUIState.id
        val portion : Float = productUIState.portion
		enteredQuantityMap.update { currentMap ->
			val currentQuantity : Float = currentMap[productId] ?: 0f
			val newQuantity : Float = if(decrease) max(currentQuantity - portion, 0f) else min(currentQuantity + portion, productUIState.quantityInStock)
			if(newQuantity > 0) currentMap + (productId to newQuantity) else currentMap - productId
		}
	}
    suspend fun addToShoppingCart(productUIState : ProductUIState) {
        val productId = productUIState.id
		val currentCartEntity : ShoppingCartEntity? = mercuryShopRepository.shoppingCartDao.getOne(productId = productId)
		val currentQuantity : Float = currentCartEntity?.let { it.quantity } ?: 0f
		val newCartEntity : ShoppingCartEntity = productUIState.toShoppingCartEntity(currentQuantity = currentQuantity)
        mercuryShopRepository.shoppingCartDao.upsertShoppingCart(newCartEntity)
		updateEnteredQuantity(productId = productId, quantity = 0f)
    }
	suspend fun deleteShoppingCartItem(cartUIState : ShoppingCartUIState?) : Int {
		return cartUIState?.let {
			mercuryShopRepository.shoppingCartDao.deleteById(productId = it.productId)
		} ?: 0
	}
	suspend fun deleteAllShoppingCartItems() : Int {
		return mercuryShopRepository.shoppingCartDao.deleteAll()
	}
	suspend fun updateShoppingCartQuantity(productId : Int, quantity : Float) {
		val productUIState : ProductUIState? = productUIStates.value[productId]
		if(productUIState != null) {
			val cartQuantity: Float = min(quantity, productUIState.quantityInStock)
			if (cartQuantity > 0) {
				val shoppingCartEntity = ShoppingCartEntity(
					productId = productId,
					quantity = cartQuantity,
					amount = cartQuantity * productUIState.price
				)
				mercuryShopRepository.shoppingCartDao.upsertShoppingCart(shoppingCartEntity)
				updateEnteredQuantity(productId = productId, quantity = cartQuantity)
			}
			else {
				mercuryShopRepository.shoppingCartDao.deleteById(productId = productId)
				updateEnteredQuantity(productId = productId, quantity = 0f)
			}
		}
	}
    suspend fun stepShoppingCartQuantity(cartUIState : ShoppingCartUIState, decrease: Boolean = false) {
        val productId = cartUIState.productId
        val productUIState : ProductUIState? = productUIStates.value[productId]
        if(productUIState != null) {
            val cartQuantity: Float =
                if (decrease) max(cartUIState.quantity - productUIState.portion, 0f)
                else min(cartUIState.quantity + productUIState.portion, productUIState.quantityInStock)
            if (cartQuantity >= 0) {
                val shoppingCartEntity = ShoppingCartEntity(
                    productId = cartUIState.productId,
                    quantity = cartQuantity,
                    amount = cartQuantity * productUIState.price
                )
                mercuryShopRepository.shoppingCartDao.upsertShoppingCart(shoppingCartEntity)
				updateEnteredQuantity(productId = productId, quantity = cartQuantity)
            }
			else {
				mercuryShopRepository.shoppingCartDao.deleteById(productId = productId)
				updateEnteredQuantity(productId = productId, quantity = 0f)
			}
        }
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
	suspend fun stepOrderItemQuantity(orderItemUIState : OrderItemUIState, decrease: Boolean = false) {
		val productId = orderItemUIState.productId
		val productUIState : ProductUIState? = productUIStates.value[productId]
		if(productUIState != null) {
			val orderItemQuantity: Float =
				if (decrease) max(orderItemUIState.quantity - productUIState.portion, 0f)
				else min(orderItemUIState.quantity + productUIState.portion, productUIState.quantityInStock)
			if (orderItemQuantity >= 0) {
				val orderItemEntity = OrderItemEntity(
					orderId = orderItemUIState.orderId,
					productId = productId,
					quantity = orderItemQuantity,
					amount = orderItemQuantity * productUIState.price
				)
				mercuryShopRepository.orderItemsDao.upsertOrderItem(orderItemEntity)
				updateEnteredQuantity(productId = productId, quantity = orderItemQuantity)
			}
		}
	}
	suspend fun deleteOrderItem(orderItemUIState : OrderItemUIState?) : Int {
		return orderItemUIState?.let {
			mercuryShopRepository.orderItemsDao.deleteById(orderId = it.orderId, productId = it.productId)
		} ?: 0
	}
	suspend fun deleteAllItemsOfOrder(orderUIState: OrderUIState?) : Int {
		return orderUIState?.let {
			mercuryShopRepository.orderItemsDao.deleteAllOfOrder(orderId = orderUIState.id)
		} ?: 0
	}
}
