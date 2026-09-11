package app.mercury.data.local.database

import android.content.Context
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.driver.bundled.BundledSQLiteDriver
import org.koin.mp.KoinPlatformTools
import java.io.File

actual fun getDatabaseBuilder(): RoomDatabase.Builder<MercuryShopDatabase> {
	val context : Context = KoinPlatformTools.defaultContext().get().get()
	val appContext : Context = context.applicationContext
	val dbFile : File = appContext.getDatabasePath("mercury_shop")
	return Room.databaseBuilder<MercuryShopDatabase>(context = appContext, name = dbFile.absolutePath)
		.setDriver(BundledSQLiteDriver())
		.fallbackToDestructiveMigration(true)
		.setJournalMode(RoomDatabase.JournalMode.WRITE_AHEAD_LOGGING)
}
