package app.mercury.data.local.database

import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.driver.bundled.BundledSQLiteDriver
import platform.Foundation.NSDocumentDirectory
import platform.Foundation.NSFileManager
import platform.Foundation.NSUserDomainMask

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
		factory = { ProductsDatabaseConstructor.initialize() }
	)
	.setDriver(BundledSQLiteDriver())
	.fallbackToDestructiveMigration(true)
}
