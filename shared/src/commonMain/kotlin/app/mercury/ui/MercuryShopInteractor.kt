//
//  MercuryShopInteractor.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.ui

import androidx.room.Ignore
import app.mercury.data.local.database.MercuryShopRepository
import app.mercury.data.local.entities.OrderEntity
import app.mercury.data.local.entities.ProductEntity
import app.mercury.data.local.entities.ShoppingCartEntity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlin.math.min
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

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
    var enteredQuantityList : MutableStateFlow<List<EnteredQuantity>>(emptyList())
	val shopUIStates : StateFlow<List<MercuryShopUIState>> = combine(
        mercuryShopRepository.productsDao.getAll(),
        mercuryShopRepository.shoppingCartDao.getAll(),
        mercuryShopRepository.ordersDao.getAll(),
		enteredQuantityList
    ) {
        products, cartItems, orders, enteredQuantities ->
        products.map { product ->
            val portion : Float = if(product.portion > 0) product.portion else 1f
			val enteredQuantity : Float? = enteredQuantityList.find { it.productId == product.id }?.let { it.quantity }
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
    fun addToShoppingCart(shopUIState : MercuryShopUIState) {
        CoroutineScope(Dispatchers.IO).launch {
            mercuryShopRepository.shoppingCartDao.insertOneOrIgnore(
                shoppingCartEntity = ShoppingCartEntity(
                    productId = shopUIState.product.id
                )
            )
            mercuryShopRepository.shoppingCartDao.updateQuantity(
                productId = shopUIState.product.id,
                quantity = shopUIState.enteredQuantity
            )
        }
    }
    fun stepShoppingCartQuantity(cartUIState : MercuryShopUIState, decrease: Boolean = false) {
        if(decrease)
            cartUIState.cartQuantity = min(cartUIState.cartQuantity - cartUIState.portion, 0f)
        else
            cartUIState.cartQuantity = min(cartUIState.cartQuantity + cartUIState.portion, cartUIState.quantityInStock)
        if(cartUIState.cartQuantity >= 0) {
            CoroutineScope(Dispatchers.IO).launch {
                mercuryShopRepository.shoppingCartDao.insertOneOrIgnore(
                    shoppingCartEntity = ShoppingCartEntity(
                        productId = cartUIState.product.id
                    )
                )
                mercuryShopRepository.shoppingCartDao.updateQuantity(
                    productId = cartUIState.product.id,
                    quantity = cartUIState.cartQuantity
                )
            }
        }
    }

}
