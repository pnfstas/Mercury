package app.mercury.data.local.database

import app.mercury.data.local.entities.ProductEntity
import com.fleeksoft.ksoup.Ksoup
import com.fleeksoft.ksoup.nodes.Document
import com.fleeksoft.ksoup.nodes.Element
import com.fleeksoft.ksoup.select.Elements
import io.ktor.client.HttpClient
import io.ktor.client.request.get
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsText
import io.ktor.http.HttpStatusCode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.launch

class ProductsRepository(
	val coroutineScope: CoroutineScope,
	val productsDao: ProductsDao,
	val httpClient : HttpClient
) {

	fun updateProducts() {
		coroutineScope.launch(Dispatchers.IO) {
			//val httpClient = HttpClient()
			val httpResponseCatalog : HttpResponse = httpClient.get("https://mercury-food-store.tilda.ws/katalog")
			val httpResponseEliteCatalog : HttpResponse = httpClient.get("https://mercury-food-store.tilda.ws/katalog/440967997433-elitnie-siri")
			if(httpResponseCatalog.status == HttpStatusCode.OK && httpResponseEliteCatalog.status == HttpStatusCode.OK) {
				val htmlContentCatalog = httpResponseCatalog.bodyAsText()
				val htmlContentEliteCatalog = httpResponseEliteCatalog.bodyAsText()
				val htmlDocumentCatalog : Document = Ksoup.parse(htmlContentCatalog)
				val htmlDocumentEliteCatalog : Document = Ksoup.parse(htmlContentEliteCatalog)
				val divElementsCatalog: Elements = htmlDocumentCatalog.select("div.js-product.t-catalog__card:nth-of-type(even)")
				val divElementsEliteCatalog: Elements = htmlDocumentEliteCatalog.select("div.js-product.t-catalog__card:nth-of-type(even)")
				val inputElements: Elements = htmlDocumentCatalog.select("input.t-catalog__prod__quantity-input:nth-child(2)")
				var inputElementIndex : Int = 0
				var products = mutableListOf<ProductEntity>()
				for(divElementProduct in divElementsCatalog) {
					val outerText : String = divElementProduct.wholeOwnText()
					val listDescription : List<String> = outerText.split('\n')
					if(listDescription.size >= 5) {
						val divElementEliteProduct : Element? = divElementsEliteCatalog.select(":containsOwn('${outerText}')").first()
						val name : String = listDescription[0]
						val description : String = listDescription[1]
						val elite : Boolean = divElementEliteProduct != null
						val price : Float = listDescription[2].toFloat()
						val minAmount : Float = inputElements[inputElementIndex].attr("min").toFloatOrNull() ?: 0f
						val maxAmount : Float = inputElements[inputElementIndex].attr("max").toFloatOrNull() ?: 0f
						var amountInOrder : Float = inputElements[inputElementIndex].attr("value").toFloatOrNull() ?: 0f
						val picture : String = divElementProduct.attribute("product.data-poduct-img")?.value ?: ""
						val url : String = divElementProduct.attribute("product.data-poduct-url")?.value ?: ""
						if(!name.isNullOrBlank() && !description.isNullOrBlank() && price > 0) {
							val productEntity = ProductEntity(
								name = name,
								description = description,
								elite = elite,
								price = price,
								minAmount = minAmount,
								maxAmount = maxAmount,
								amountInOrder = amountInOrder,
								picture = picture,
								url = url
							)
							products.add(productEntity)
						}
					}
				}
				if(products.size > 0) {
					productsDao.insertAll(products)
				}
			}
		}
	}
}
