import androidx.compose.ui.window.ComposeUIViewController
import com.maksimowiczm.findmyip.FindMyIPApp
import platform.UIKit.UIViewController

fun MainViewController(): UIViewController = ComposeUIViewController { FindMyIPApp() }
