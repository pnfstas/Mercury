package app.mercury

import android.app.Application
import app.mercury.di.KoinHelper
import app.mercury.di.KoinHelper.Companion.initKoin

class AndroidApp : Application() {
    override fun onCreate() {
        super.onCreate()
        KoinHelper.initKoin()
    }
}