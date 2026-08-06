package app.mercury.di

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.SupervisorJob
import org.koin.core.context.startKoin
import org.koin.core.module.Module
import org.koin.dsl.module

val productsModule = module {
	single<CoroutineScope> {
		CoroutineScope(SupervisorJob() + Dispatchers.IO)
	}
}

fun initKoin(additionalModules: List<Module> = emptyList()) {
	startKoin {
		modules(productsModule + additionalModules)
	}
}