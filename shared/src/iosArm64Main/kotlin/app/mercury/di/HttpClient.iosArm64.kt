package app.mercury.di

import io.ktor.client.HttpClient
import io.ktor.client.engine.HttpClientEngine

actual fun getHttpClient(engine: HttpClientEngine) : HttpClient {
    return HttpClient()
}