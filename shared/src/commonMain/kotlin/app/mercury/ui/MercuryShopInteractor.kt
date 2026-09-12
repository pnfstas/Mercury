//
//  MercuryShopInteractor.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.ui

import androidx.room.Ignore
import app.mercury.data.local.database.MercuryShopRepository
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.flow.MutableStateFlow
import kotlin.math.min
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
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
}

data class EnteredQuantity (
	val productId : Int,
	var quantity : Float = 0f
)

class MercuryShopInteractor(private val mercuryShopRepository: MercuryShopRepository) {
    val enteredQuantityMap = MutableStateFlow<MutableMap<Int, Float>>(mutableMapOf())
	val shopUIStates : StateFlow<List<MercuryShopUIState>> = combine(
        mercuryShopRepository.productsDao.getAll(),
        mercuryShopRepository.shoppingCartDao.getAll(),
        mercuryShopRepository.ordersDao.getAll(),
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
	fun stepEnteredQuantity(shopUIState : MercuryShopUIState, decrease: Boolean = false) {
        val productId = shopUIState.product.id
        val portion : Float = shopUIState?.let { it.portion } ?: 0f
        var enteredQuantity : Float = enteredQuantityMap.value[productId] ?: 0f
        if(decrease)
            enteredQuantityMap.value[productId] = min(enteredQuantity - portion, 0f)
        else {
            val quantityInStock: Float = shopUIState?.let { it.quantityInStock } ?: 0f
            enteredQuantityMap.value[productId] = min(enteredQuantity + portion, quantityInStock)
        }
	}
    fun addToShoppingCart(shopUIState : MercuryShopUIState) {
        val productId = shopUIState.product.id
        CoroutineScope(Dispatchers.IO).launch {
            mercuryShopRepository.shoppingCartDao.insertOneOrIgnore(
                shoppingCartEntity = ShoppingCartEntity(
                    productId = productId
                )
            )
            mercuryShopRepository.shoppingCartDao.updateQuantity(
                productId = productId,
                quantity = shopUIState.enteredQuantity
            )
        }
        enteredQuantityMap.value.remove(shopUIState.product.id)
    }
    fun stepShoppingCartQuantity(cartUIState : MercuryShopUIState, decrease: Boolean = false) {
        val productId = cartUIState.product.id
        var cartQuantity : Float = 0f
        if(decrease)
            cartQuantity = min(cartUIState.cartQuantity - cartUIState.portion, 0f)
        else
            cartQuantity = min(cartUIState.cartQuantity + cartUIState.portion, cartUIState.quantityInStock)
        if(cartQuantity >= 0) {
            CoroutineScope(Dispatchers.IO).launch {
                mercuryShopRepository.shoppingCartDao.insertOneOrIgnore(
                    shoppingCartEntity = ShoppingCartEntity(
                        productId = productId
                    )
                )
                mercuryShopRepository.shoppingCartDao.updateQuantity(
                    productId = productId,
                    quantity = cartQuantity
                )
            }
            if(cartQuantity > 0) {
                enteredQuantityMap.value[productId] = cartQuantity
            }
            else {
                enteredQuantityMap.value.remove(productId)
            }
        }
    }
}
