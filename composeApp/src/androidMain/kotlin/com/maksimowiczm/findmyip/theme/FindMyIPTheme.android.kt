package com.maksimowiczm.findmyip.theme

import android.os.Build
import androidx.activity.compose.LocalActivity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.MaterialExpressiveTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.platform.LocalContext
import androidx.core.view.WindowInsetsControllerCompat

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
actual fun FindMyIpTheme(content: @Composable (() -> Unit)) {
    val isDark = isSystemInDarkTheme()

    val activity = LocalActivity.current
    LaunchedEffect(isDark) {
        val window = activity!!.window

        WindowInsetsControllerCompat(window, window.decorView).apply {
            isAppearanceLightStatusBars = !isDark
            isAppearanceLightNavigationBars = !isDark
        }
    }

    val colorScheme =
        when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
                val context = LocalContext.current
                if (isDark) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
            }

            isDark -> darkColorScheme()
            else -> lightColorScheme()
        }

    MaterialExpressiveTheme(colorScheme = colorScheme, content = content)
}
