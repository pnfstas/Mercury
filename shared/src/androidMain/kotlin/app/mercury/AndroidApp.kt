package app.mercury

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.Modifier
import com.multiplatform.webview.web.WebView
import com.multiplatform.webview.web.rememberWebViewState

@Composable
fun AndroidApp() {
    MaterialTheme {
        val webViewState = rememberWebViewState("https://mercury-food-store.tilda.ws/")
        WebView(
            state = webViewState,
            modifier = Modifier.fillMaxSize()
        )
    }
}

@Preview
@Composable
fun AppAndroidPreview() {
	AndroidApp()
}