package app.mercury.di

import app.mercury.data.local.database.ProductsDatabase
import app.mercury.data.local.database.ProductsRepository
import app.mercury.ui.ProductsInteractor
import io.ktor.client.HttpClient
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.SupervisorJob
import org.koin.core.component.KoinComponent
import org.koin.core.component.get
import org.koin.core.context.startKoin
import org.koin.core.module.Module
import org.koin.dsl.module

val productsModule = module {
	single<CoroutineScope> {
		CoroutineScope(SupervisorJob() + Dispatchers.IO)
	}
	single<HttpClient> {
		getHttpClient()
	}
	single<ProductsDatabase> {
		app.mercury.data.local.database.getDatabaseBuilder().build()
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

expect fun getHttpClient() : HttpClient

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
	fun getProductsInteractor() : ProductsInteractor = get()
	/*
	fun getProductsInteractor() : ProductsInteractor {
		val scope = get<CoroutineScope>()
		println("Scope OK: $scope")
		val client = get<HttpClient>()
		println("HttpClient OK: $client")
		val dao = get<app.mercury.data.local.database.ProductsDatabase>().productsDao()
		println("DAO OK: $dao")
		val repo = get<ProductsRepository>()
		println("Repository OK: $repo")
		return get()
	}
	*/
	fun getProductsRepository() : ProductsRepository = get()
}
