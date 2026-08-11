package app.mercury.data.local.database

import app.mercury.data.local.entities.ProductEntity
import com.fleeksoft.ksoup.Ksoup
import com.fleeksoft.ksoup.nodes.Document
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
	val httpClient: HttpClient
) {

	fun updateProducts() {
		coroutineScope.launch(Dispatchers.IO) {
			/*
			val client = HttpClient {
				install(ContentNegotiation) {
					json(Json {
						ignoreUnknownKeys = true 	// игнорировать неизвестные поля
						isLenient = true         	// мягкий синтаксис
						prettyPrint = true			// Разрешить перенос строк и пробелы в JSON
						coerceInputValues = true	// Если сервер пришлет null вместо обязательного поля, Ktor подставит default
					})
				}
			}
			*/
			val httpClient = HttpClient()
			val httpResponse : HttpResponse = httpClient.get("https://mercury-food-store.tilda.ws/katalog")
			if(httpResponse.status == HttpStatusCode.OK) {
				val htmlContent = httpResponse.bodyAsText()
				val htmlDocument : Document = Ksoup.parse(htmlContent)
				val elements: Elements = htmlDocument.select("div.js-product.t-catalog__card")
				var products = mutableListOf<ProductEntity>()
				for(element in elements) {
					val listDescription : List<String> = element?.wholeOwnText()?.split('\n') ?: emptyList()
					if(listDescription.size >= 3) {
						val name = listDescription[0]
						val description = listDescription[1]
						val price = listDescription[2].toFloat()
						val picture = element.attribute("product.data-poduct-img")?.value ?: ""
						val url = element.attribute("product.data-poduct-url")?.value ?: ""
						if(name?.isNullOrBlank() == false && description?.isNullOrBlank() == false && price > 0) {
							val productEntity = ProductEntity(
								name = name,
								description = description,
								price = price,
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