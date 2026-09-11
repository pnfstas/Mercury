//
//  MercuryShopInteractor.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.ui

import androidx.collection.emptyLongSet
import androidx.room.Ignore
import app.mercury.data.local.database.MercuryShopRepository
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlin.math.min
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn

data class MercuryShopUIState (
    val product : ProductEntity,
    val portion : Float = 0f,
    var quantityInStock : Float = 0f,
    var enteredQuantity : Float = 0f,
    var cartQuantity : Float = 0f,
    var orderedQuantity : Float = 0f
) {
    @get:Ignore
    val inStock : Boolean
        get() = quantityInStock > 0
}

class MercuryShopInteractor(private val mercuryShopRepository: MercuryShopRepository) {
    val shopUIStates : StateFlow<List<MercuryShopUIState>> = combine(
        mercuryShopRepository.productsDao.getAll(),
        mercuryShopRepository.shoppingCartDao.getAll(),
        mercuryShopRepository.ordersDao.getAll()
    ) {
        products, cartItems, orders ->
        products.map { product ->
            val portion : Float = if(product.portion > 0) product.portion else 1f
            val cartItem : ShoppingCartEntity? = cartItems.find { it.productId == product.id }
            val orderedQuantity : Float = orders.filter { it.productId == product.id }.sumOf { it.quantity.toDouble() }.toFloat()
            MercuryShopUIState(
                product = product,
                portion = portion,
                quantityInStock = product.quantity,
                enteredQuantity  = if(portion <= product.quantity) portion else 0f,
                cartQuantity = cartItem?.quantity ?: 0f,
                orderedQuantity = orderedQuantity
            )
        }
    }
    .stateIn(
        mercuryShopRepository.coroutineScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList())
    val cartUIStates = shopUIStates.map { list ->
        list.filter { it.cartQuantity > 0 }
    }
    .stateIn(
        mercuryShopRepository.coroutineScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList())
    val orderUIStates = shopUIStates.map { list ->
        list.filter { it.orderedQuantity > 0 }
    }
	.stateIn(
		mercuryShopRepository.coroutineScope,
		started = SharingStarted.WhileSubscribed(5000),
		initialValue = emptyList())
    val shoppingCart : StateFlow<List<ShoppingCartEntity>> = mercuryShopRepository.shoppingCartDao.getAll()
        .stateIn(
            mercuryShopRepository.coroutineScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList())
    val orders : StateFlow<List<OrderEntity>> = mercuryShopRepository.ordersDao.getAll()
        .stateIn(
            mercuryShopRepository.coroutineScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList())
	init {
        mercuryShopRepository.updateProducts()
	}
	fun stepEnteredQuantity(shopUIState : MercuryShopUIState, decrease: Boolean = false) {
        if(decrease)
            shopUIState.enteredQuantity = min(shopUIState.enteredQuantity - shopUIState.portion, 0f)
        else
            shopUIState.enteredQuantity = min(shopUIState.enteredQuantity + shopUIState.portion, shopUIState.quantityInStock)
	}
    suspend fun addToShoppingCartOrUpdateQuantity(shopUIState : MercuryShopUIState) {
        mercuryShopRepository.shoppingCartDao.insertOneOrIgnore(shoppingCartEntity = ShoppingCartEntity(productId = shopUIState.product.id))
        mercuryShopRepository.shoppingCartDao.updateQuantity(productId = shopUIState.product.id, quantity = shopUIState.enteredQuantity)
    }
}
