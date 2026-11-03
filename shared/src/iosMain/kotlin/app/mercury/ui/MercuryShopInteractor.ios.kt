package app.mercury.ui

actual class ReflectionHelper {
    actual fun <T : Any> copyWith(instance: T, propertyName: String, propertyValue: Any?) : T? {
        error("Reflrction is not supported on ios platform")
    }
}
