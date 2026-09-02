package app.mercury.data.local.database

import app.mercury.data.local.entities.ProductEntity
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.client.statement.HttpResponse
import io.ktor.http.HttpStatusCode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable

@Serializable
data class TildaProduct (
	val sku : String?,
	val title: String?,
	val descr : String?,
	val url: String?,
	val quantity: String?,
	val price: String?,
	val priceold: String?,
	val img: String?
)

class ProductsRepository(
	val coroutineScope: CoroutineScope,
	val productsDao: ProductsDao,
	val httpClient : HttpClient
) {
	fun updateProducts() {
		coroutineScope.launch(Dispatchers.IO) {
			try {
				val catalogUrl = "https://store.tildaapi.com/api/getproductslist/?storepartuid=727848246912&recid=2349783881&c=1788331263307&slice=3&size=100"
				val eliteCatalogUrl = "https://store.tildaapi.com/api/getproductslist/?storepartuid=727848246912&recid=2349783881&c=1788251804637&getallparts=true&getoptions=true&slice=1&size=100"
				val httpResponseCatalog : HttpResponse = httpClient.get(catalogUrl)
				val httpResponseEliteCatalog : HttpResponse = httpClient.get(eliteCatalogUrl)
				if(httpResponseCatalog.status == HttpStatusCode.OK && httpResponseEliteCatalog.status == HttpStatusCode.OK) {
					val tildaCatalog : List<TildaProduct> = httpResponseCatalog.body()
					val tildaEliteCatalog : List<TildaProduct> = httpResponseEliteCatalog.body()
					println("tildaCatalog: $tildaCatalog")
					println("tildaEliteCatalog: $tildaEliteCatalog")
					var productEntities = mutableListOf<ProductEntity>()
					for(product in tildaCatalog) {
						val productEntity = ProductEntity (
							title = product.title ?: "",
							descr = product.descr ?: "",
							elite = tildaEliteCatalog.any { it -> it.sku == product.sku  },
							price = product.price?.toFloatOrNull() ?: 0f,
							quantity = product.quantity?.toFloatOrNull() ?: 0f,
							amountInOrder = 0f,
							image = product.img ?: "",
							url = product.url ?: ""
						)
						println("productEntity: $productEntity")
						productEntities.add(productEntity)
					}
					if(productEntities.size > 0) {
						productsDao.insertAll(productEntities)
					}
				}
			}
			catch(e: Exception) {
				println(e)
			}
		}
	}
}
