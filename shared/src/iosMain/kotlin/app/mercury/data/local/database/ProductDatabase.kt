package app.mercury.data.local.database

import androidx.room.Room
import androidx.room.RoomDatabase
import platform.Foundation.NSDocumentDirectory
import platform.Foundation.NSFileManager
import platform.Foundation.NSUserDomainMask
import app.mercury.data.local.database.ProductsDatabase

@OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)
actual fun getDatabaseBuilder(): RoomDatabase.Builder<ProductsDatabase> {
	val documentDirectory = NSFileManager.defaultManager.URLForDirectory(
		directory = NSDocumentDirectory,
		inDomain = NSUserDomainMask,
		appropriateForURL = null,
		create = true,
		error = null
	)
	val dbFilePath = documentDirectory!!.path + "/products.db"

	return Room.databaseBuilder<ProductsDatabase>(
		name = dbFilePath,
		factory = { ProductDatabase_Impl() } // Используем сгенерированный класс Room
	)
}