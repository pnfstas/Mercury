package app.mercury.resources

import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.addressOf
import kotlinx.cinterop.usePinned
import platform.Foundation.NSData
import platform.Foundation.dataWithBytes
import platform.UIKit.UIImage

import org.jetbrains.compose.resources.ExperimentalResourceApi
import org.jetbrains.compose.resources.InternalResourceApi
import org.jetbrains.compose.resources.readResourceBytes


@OptIn(ExperimentalResourceApi::class, InternalResourceApi::class, ExperimentalForeignApi::class)
suspend fun loadSharedDrawable(resourceName: String): UIImage? {
    return try {
        val bytes = readResourceBytes("drawable/$resourceName")
        val nsData = bytes.usePinned { pinned ->
            NSData.dataWithBytes(pinned.addressOf(0), bytes.size.toULong())
        }
        UIImage.imageWithData(nsData)
    }
    catch (e: Exception) {
        null
    }
}
