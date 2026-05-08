
import 'dart:io';

class PlatformUtils {
  static String? getCurrentPlatformHomeDir() {
    
    Map<String, String> envVars = Platform.environment;

    if (Platform.isMacOS) {
      return envVars['HOME'];
    } else if (Platform.isLinux) {
      return envVars['HOME'];
    } else if (Platform.isWindows) {
      return envVars['UserProfile'];
    }

    // If unknown platform
    return null;
  }
}
