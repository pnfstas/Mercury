package app.mercury.ui

import kotlin.reflect.KClass
import kotlin.reflect.KFunction
import kotlin.reflect.KParameter
import kotlin.reflect.KProperty1
import kotlin.reflect.full.declaredMemberProperties
import kotlin.reflect.full.functions

actual class ReflectionHelper {
    actual fun <T : Any> copyWith(instance: T, propertyName: String, propertyValue: Any?) : T? {
        var copyOfInstance : T? = null
        val kClass : KClass<T> = instance::class as KClass<T>
        val kFuncCopy : KFunction<*>? = kClass.functions.find { "copy".equals(it.name) }
        val properties : List<KProperty1<T, *>> = kClass.declaredMemberProperties.filter { it?.name?.isNullOrBlank() == false }
        if(kFuncCopy != null && !properties.isEmpty()) {
            val kParameters : List<KParameter> = kFuncCopy.parameters
            val kParamInstance : KParameter? = kParameters.firstOrNull { it.kind == KParameter.Kind.INSTANCE }
            val kParamForSet : KParameter? = kParameters.firstOrNull { propertyName.equals(it.name) }
            if(kParamInstance != null && kParamForSet != null
                && kParameters.all { param -> param == kParamInstance || properties.any { it.name.equals(param.name) } }) {
                val mapParamValues : Map<KParameter, Any?> = mapOf(
                    kParamInstance to instance,
                    kParamForSet to propertyValue
                )
                copyOfInstance = kFuncCopy.callBy(args = mapParamValues) as? T
            }
        }
        return copyOfInstance
    }
}
