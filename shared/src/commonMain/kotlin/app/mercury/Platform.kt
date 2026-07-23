package app.mercury

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform