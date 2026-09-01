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
			val httpResponseCatalog : HttpResponse = httpClient.get("https://mercury-food-store.tilda.ws")
			val httpResponseEliteCatalog : HttpResponse = httpClient.get("https://mercury-food-store.tilda.ws/katalog/440967997433-elitnie-siri")
			if(httpResponseCatalog.status == HttpStatusCode.OK && httpResponseEliteCatalog.status == HttpStatusCode.OK) {
				val htmlContentCatalog = httpResponseCatalog.bodyAsText()
				val htmlContentEliteCatalog = httpResponseEliteCatalog.bodyAsText()
				val htmlDocumentCatalog : Document = Ksoup.parse(htmlContentCatalog)
				val htmlDocumentEliteCatalog : Document = Ksoup.parse(htmlContentEliteCatalog)
				println("htmlContentCatalog: $htmlContentCatalog")
				//println("htmlDocumentCatalog: $htmlDocumentCatalog")
				/*
				val divElementsCatalog: Elements = htmlDocumentCatalog.select("div.js-product.t-catalog__card:nth-of-type(even)")
				val divElementsEliteCatalog: Elements = htmlDocumentEliteCatalog.select("div.js-product.t-catalog__card:nth-of-type(even)")
				*/
				val divAllElementsCatalog: Elements = htmlDocumentCatalog.select("div.js-product.t-catalog__card")
				val divAllElementsEliteCatalog: Elements = htmlDocumentEliteCatalog.select("div.js-product.t-catalog__card")
				val divElementsCatalog: List<Element> = divAllElementsCatalog.filterIndexed { index, _ -> index % 2 == 1 }
				val divElementsEliteCatalog: Elements = Elements(divAllElementsEliteCatalog
					.filterIndexed { index, _ -> index % 2 == 1 })
				val inputElements: Elements = htmlDocumentCatalog.select("input.t-catalog__prod__quantity-input:nth-child(2)")
				println("divAllElementsCatalog: $divAllElementsCatalog")
				println("divElementsCatalog: $divElementsCatalog")
				var inputElementIndex : Int = 0
				var products = mutableListOf<ProductEntity>()
				for(divElementProduct in divElementsCatalog) {
					val outerText : String = divElementProduct.wholeOwnText()
					val listDescription : List<String> = outerText.split('\n')
					if(listDescription.size >= 5) {
						val divElementEliteProduct : Element? = divElementsEliteCatalog.select(":containsOwn('${outerText}')").first()
						val productEntity = ProductEntity (
							name = listDescription[0],
							productInfo = listDescription[1],
							elite = divElementEliteProduct != null,
							price = listDescription[2].toFloat(),
							minAmount =
								inputElements[inputElementIndex].attr("min").toFloatOrNull() ?: 0f,
							maxAmount =
								inputElements[inputElementIndex].attr("max").toFloatOrNull() ?: 0f,
							amountInOrder =
								inputElements[inputElementIndex].attr("value").toFloatOrNull() ?: 0f,
							picture =
								divElementProduct.attribute("product.data-poduct-img")?.value ?: "",
							url =
								divElementProduct.attribute("product.data-poduct-url")?.value ?: ""
						)
						println("ProductEntity: $productEntity")
						if(!productEntity.name.isNullOrBlank() && !productEntity.productInfo.isNullOrBlank() && productEntity.price > 0) {
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
