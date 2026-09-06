package app.mercury.di

import app.mercury.data.local.database.MercuryShopDatabase
import app.mercury.data.local.database.MercuryShopRepository
import app.mercury.ui.MercuryShopInteractor
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

val mercuryModule = module {
	single<CoroutineScope> {
		CoroutineScope(SupervisorJob() + Dispatchers.IO)
	}
	single<HttpClient> {
		getHttpClient()
	}
	single<MercuryShopDatabase> {
		app.mercury.data.local.database.getDatabaseBuilder().build()
	}
	single {
		get<MercuryShopDatabase>().productsDao()
	}
	single {
		get<MercuryShopDatabase>().shoppingCartDao()
	}
	single {
		get<MercuryShopDatabase>().ordersDao()
	}
	single {
		MercuryShopRepository(
			coroutineScope = get(),
			productsDao = get(),
			shoppingCartDao = get(),
			ordersDao = get(),
			httpClient = get()
		)
	}
	factory {
		MercuryShopInteractor(mercuryShopRepository = get())
	}
}

expect fun getHttpClient() : HttpClient

class KoinHelper : KoinComponent {
	companion object {
		fun initKoin(additionalModules: List<Module> = emptyList()) {
			startKoin {
				modules(mercuryModule + additionalModules)
			}
		}
		fun initKoinIos() {
			initKoin(emptyList())
		}
	}
	fun getMercuryShopInteractor() : MercuryShopInteractor = get()
	/*
	fun getMercuryShopInteractor() : MercuryShopInteractor {
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
	fun getMercuryShopRepository() : MercuryShopRepository = get()
}
