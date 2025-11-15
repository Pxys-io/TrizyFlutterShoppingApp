class DebugConfig {
  /// Toggle this to enable/disable API debugging
  /// Set to true to show all API calls, false to hide debugging messages
  static bool apiDebuggingEnabled = true;
  
  /// Method to toggle debugging on/off programmatically
  static void toggleApiDebugging() {
    apiDebuggingEnabled = !apiDebuggingEnabled;
    print('API Debugging ${apiDebuggingEnabled ? "ENABLED" : "DISABLED"}');
  }
  
  /// Method to enable debugging
  static void enableApiDebugging() {
    apiDebuggingEnabled = true;
    print('API Debugging ENABLED');
  }
  
  /// Method to disable debugging
  static void disableApiDebugging() {
    apiDebuggingEnabled = false;
    print('API Debugging DISABLED');
  }
}