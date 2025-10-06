/// API Configuration

/// 1. Copy this file to lib/config/api_config.dart
/// 2. Replace the values with your actual API endpoints
/// 3. Make sure api_config.dart is in .gitignore

class ApiConfig {
  // ===================================
  // BASE URL CONFIGURATION
  // ===================================

  /// Main API Base URL
  /// For development:
  /// - Android Emulator: use 10.0.2.2 (maps to localhost)
  /// - iOS Simulator: use 127.0.0.1 or your computer's IP
  /// - Real Device: use your computer's local network IP (e.g., 192.168.1.x)
  /// For production: use your actual domain/server IP
  static const String baseUrl = 'http://10.0.2.2:8080/api/users';

  /// Alternative base URLs for different environments
  static const String productionUrl =
      'https://your-production-domain.com/api/users';
  static const String stagingUrl = 'https://staging.your-domain.com/api/users';

  // ===================================
  // THIRD-PARTY API KEYS
  // ===================================

  /// MapTiler API Key
  /// Get your free API key at: https://www.maptiler.com/
  /// Free tier: 100,000 tile requests per month
  static const String mapTilerApiKey = 'YOUR_MAPTILER_API_KEY_HERE';

  // ===================================
  // FEATURE FLAGS
  // ===================================

  static const bool enableDebugMode = true;
  static const int apiTimeout = 30000; // milliseconds

  // ===================================
  // HELPER METHODS
  // ===================================

  /// Get current environment base URL
  static String getCurrentBaseUrl() {
    // You can implement environment detection logic here
    // For now, returns the default development URL
    return baseUrl;
  }

  /// Get MapTiler tile URL with API key
  static String getMapTilerUrl() {
    return 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$mapTilerApiKey';
  }

  /// Validate if configuration is set up properly
  static bool isConfigured() {
    return mapTilerApiKey != 'YOUR_MAPTILER_API_KEY_HERE' && baseUrl.isNotEmpty;
  }
}
