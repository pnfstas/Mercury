package app.mercury.ui

import app.mercury.data.local.database.MercuryShopRepository
import app.mercury.data.local.entities.ProductEntity
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class MercuryShopInteractor(private val mercuryShopRepository: MercuryShopRepository) {
    val products : StateFlow<List<ProductEntity>> = mercuryShopRepository.productsDao.getAll()
        .stateIn(
            mercuryShopRepository.coroutineScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList())
	init {
        mercuryShopRepository.updateProducts()
	}
    suspend fun updateAmountInOrder(id : Int, amount : Float) {
        mercuryShopRepository.productsDao.updateAmountInOrder(id = id, amount = amount)
    }
}
