package app.mercury

import android.app.Application
import app.mercury.di.initKoin

class AndroidApp : Application() {
    override fun onCreate() {
        super.onCreate()
        initKoin()
    }
}