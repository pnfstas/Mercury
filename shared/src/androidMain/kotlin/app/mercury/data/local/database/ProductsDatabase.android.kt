package app.mercury.data.local.database

import android.content.Context
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.driver.bundled.BundledSQLiteDriver
import org.koin.mp.KoinPlatformTools
import java.io.File

actual fun getDatabaseBuilder(): RoomDatabase.Builder<ProductsDatabase> {
	val context : Context = KoinPlatformTools.defaultContext().get().get()
	val appContext : Context = context.applicationContext
	val dbFile : File = appContext.getDatabasePath("products")
	return Room.databaseBuilder<ProductsDatabase>(context = appContext, name = dbFile.absolutePath)
		.setDriver(BundledSQLiteDriver())
		.setJournalMode(RoomDatabase.JournalMode.WRITE_AHEAD_LOGGING)
}
