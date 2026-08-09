package app.mercury.data.local.database

import app.mercury.data.local.entities.ProductEntity
import io.ktor.client.HttpClient
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow

class ProductsRepository(
	val coroutineScope: CoroutineScope,
	val productsDao: ProductsDao,
	val httpClient: HttpClient
) {

	fun updateProducts() : Flow<List<ProductEntity>> {
		val httpClient = HttpClient()

	}
}