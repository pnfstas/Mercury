package app.mercury.di

import app.mercury.data.local.database.ProductsDatabase
import app.mercury.data.local.database.ProductsRepository
import app.mercury.ui.ProductsInteractor
import io.ktor.client.HttpClient
import io.ktor.client.engine.HttpClientEngine
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.SupervisorJob
import kotlinx.serialization.json.Json
import org.koin.core.component.KoinComponent
import org.koin.core.component.get
import org.koin.core.context.startKoin
import org.koin.core.module.Module
import org.koin.dsl.module
import org.koin.mp.KoinPlatform

val productsModule = module {
	single<CoroutineScope> {
		CoroutineScope(SupervisorJob() + Dispatchers.IO)
	}
	single<HttpClient> {
		HttpClient {
			install(ContentNegotiation) {
				json(Json {
					ignoreUnknownKeys = true
				})
			}
		}
	}
	single {
		get<ProductsDatabase>().productsDao()
	}
	single {
		ProductsRepository(
			coroutineScope = get(),
			productsDao = get(),
			httpClient = get()
		)
	}
	factory {
		ProductsInteractor(productsRepository = get())
	}
}

expect fun getHttpClient(engine: HttpClientEngine) : HttpClient

class KoinHelper : KoinComponent {
	companion object {
		fun initKoin(additionalModules: List<Module> = emptyList()) {
			startKoin {
				modules(productsModule + additionalModules)
			}
		}
		fun initKoinIos() {
			initKoin(emptyList())
		}
	}
	//fun getProductsInteractor() : ProductsInteractor = get()
	fun getProductsInteractor() : ProductsInteractor {
		// Шаг 1: Проверяем scope
		val scope = get<CoroutineScope>()
		println("Scope OK: $scope")

		// Шаг 2: Проверяем клиент
		val client = get<HttpClient>()
		println("HttpClient OK: $client")

		// Шаг 3: Проверяем базу (ЗДЕСЬ скорее всего упадет, если модуля с базой нет в iOS)
		val dao = get<app.mercury.data.local.database.ProductsDatabase>().productsDao()
		println("DAO OK: $dao")

		// Шаг 4: Проверяем репозиторий
		val repo = get<ProductsRepository>()
		println("Repository OK: $repo")

		return get()
	}
	fun getProductsRepository() : ProductsRepository = get()
}
