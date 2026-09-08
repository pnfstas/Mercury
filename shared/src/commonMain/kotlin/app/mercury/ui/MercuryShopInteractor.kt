//
//  MercuryShopInteractor.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.ui

import androidx.collection.emptyLongSet
import app.mercury.data.local.database.MercuryShopRepository
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlin.math.min
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn

data class ProductUIState (
    val product : ProductEntity,
    val portion : Float = 0f,
    var quantityInStock : Float = 0f,
    var enteredQuantity : Float = 0f,
    var cartQuantity : Float = 0f,
    var orderedQuantity : Float = 0f
)

class MercuryShopInteractor(private val mercuryShopRepository: MercuryShopRepository) {
    val products : StateFlow<List<ProductUIState>> = combine(
        mercuryShopRepository.productsDao.getAll(),
        mercuryShopRepository.shoppingCartDao.getAll(),
        mercuryShopRepository.ordersDao.getAll()
    ) {
        products, cartItems, orders ->
        products.map { product ->
            val portion : Float = if(product.portion > 0) product.portion else 1f
            val cartItem : ShoppingCartEntity? = cartItems.find { it.productId == product.id }
            val orderedQuantity : Float = orders.filter { it.productId == product.id }.sumOf { it.quantity.toDouble() }.toFloat()
            ProductUIState(
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
	fun stepEnteredQuantity(productUIState : ProductUIState, decrease: Boolean = false) {
        if(decrease)
            productUIState.enteredQuantity = min(productUIState.enteredQuantity - productUIState.portion, 0f)
        else
            productUIState.enteredQuantity = min(productUIState.enteredQuantity + productUIState.portion, productUIState.quantityInStock)
	}
    suspend fun updateQuantityInShoppingCart(productUIState : ProductUIState) {
        mercuryShopRepository.shoppingCartDao.insertOneOrIgnore(shoppingCartEntity = ShoppingCartEntity(productId = productUIState.product.id))
        mercuryShopRepository.shoppingCartDao.updateQuantity(productId = productUIState.product.id, quantity = productUIState.enteredQuantity)
    }
}
