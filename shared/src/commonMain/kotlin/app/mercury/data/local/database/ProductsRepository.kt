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
//import kotlinx.serialization.Transient

@Serializable
data class TildaProduct (
	val sku : String? = null,
	val title: String? = null,
	val descr : String? = null,
	val quantity: String? = null,
	val portion : Float = 0f,
	val unit : String? = null,
	val single : String? = null,
	val price: String? = null,
	val priceold: String? = null,
	val url: String? = null,
	val editions: List<TildaEdition>? = null
)

@Serializable
data class TildaEdition (
	val img: String? = null
)

@Serializable
data class TildaCatalog (
	val products : List<TildaProduct>? = null
) {
	fun appendToProductEntities(productEntities : MutableList<ProductEntity>, elite : Boolean = false) {
		try {
			if(products?.size ?: 0 > 0 ) {
				for(product in products ?: emptyList()) {
					val productEntity = ProductEntity (
						title = product.title ?: "",
						descr = product.descr ?: "",
						elite = elite,
						quantity = product.quantity?.toFloatOrNull() ?: 0f,
						portion = product.portion,
						unit = product.unit ?: "",
						single = product.single == "y",
						price = product.price?.toFloatOrNull() ?: 0f,
						oldPrice = product.priceold?.toFloatOrNull() ?: 0f,
						amountInOrder = 0f,
						image = product.editions?.getOrNull(0)?.img ?: "",
						url = product.url ?: ""
					)
					println("productEntity: $productEntity")
					productEntities.add(productEntity)
				}
			}
		}
		catch(e: Exception) {
			println(e)
		}
	}
}

class ProductsRepository(
	val coroutineScope: CoroutineScope,
	val productsDao: ProductsDao,
	val httpClient : HttpClient
) {
	fun updateProducts() {
		coroutineScope.launch(Dispatchers.IO) {
			try {
				val catalogUrl = "https://store.tildaapi.com/api/getproductslist/?storepartuid=727848246912&recid=2349783881&c=1788418420998&slice=3&size=100"
				val eliteCatalogUrl = "https://store.tildaapi.com/api/getproductslist/?storepartuid=727848246912&recid=2349783881&c=1788417818487&getallparts=true&getoptions=true&slice=1&size=100"
				val httpResponseCatalog : HttpResponse = httpClient.get(catalogUrl)
				val httpResponseEliteCatalog : HttpResponse = httpClient.get(eliteCatalogUrl)
				if(httpResponseCatalog.status == HttpStatusCode.OK && httpResponseEliteCatalog.status == HttpStatusCode.OK) {
					val tildaCatalog : TildaCatalog = httpResponseCatalog.body()
					val tildaEliteCatalog : TildaCatalog = httpResponseEliteCatalog.body()
					//println("tildaCatalog: $tildaCatalog")
					//println("tildaEliteCatalog: $tildaEliteCatalog")
					var productEntities = mutableListOf<ProductEntity>()
					tildaEliteCatalog.appendToProductEntities(productEntities = productEntities, elite = true)
					tildaCatalog.appendToProductEntities(productEntities = productEntities)
					if(productEntities.size > 0) {
						println("productEntities: $productEntities")
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
