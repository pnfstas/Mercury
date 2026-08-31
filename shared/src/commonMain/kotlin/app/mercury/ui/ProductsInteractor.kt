package app.mercury.ui

import app.mercury.data.local.database.ProductsRepository
import app.mercury.data.local.entities.ProductEntity
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class ProductsInteractor(private val productsRepository: ProductsRepository) {
    val products : StateFlow<List<ProductEntity>> = productsRepository.productsDao.getAll()
        .stateIn(
            productsRepository.coroutineScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList())
	init() {
		productsRepository.updateProducts()
	}
}
