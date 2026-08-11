package app.mercury.di

import app.mercury.data.local.database.ProductsDao
import app.mercury.data.local.database.ProductsDatabase
import app.mercury.data.local.database.ProductsRepository
import app.mercury.ui.ProductsInteractor
import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.SupervisorJob
import kotlinx.serialization.json.Json
import org.koin.core.context.startKoin
import org.koin.core.module.Module
import org.koin.dsl.module

val productsModule = module {
	single<CoroutineScope> {
		CoroutineScope(SupervisorJob() + Dispatchers.IO)
	}
	single<HttpClient> {
		HttpClient {
			install(ContentNegotiation) {
				json(Json {
					ignoreUnknownKeys = true // Чтобы Ktor не падал, если на Тильде появятся новые поля
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
	single {
		(productsRepository: ProductsRepository) -> ProductsInteractor(productsRepository = productsRepository)
	}
}

fun initKoin(additionalModules: List<Module> = emptyList()) {
	startKoin {
		modules(productsModule + additionalModules)
	}
}