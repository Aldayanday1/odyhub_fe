import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class for modern full screen UI with edge-to-edge display
class FullScreenHelper {
  /// Get top padding for status bar
  static double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Get bottom padding for navigation bar
  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// Set system UI overlay style for light background
  static void setLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Set system UI overlay style for dark background
  static void setDarkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Set system UI overlay style with custom colors
  static void setCustomStatusBar({
    Color statusBarColor = Colors.transparent,
    Brightness statusBarIconBrightness = Brightness.dark,
    Color navigationBarColor = Colors.transparent,
    Brightness navigationBarIconBrightness = Brightness.dark,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: statusBarIconBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: navigationBarColor,
        systemNavigationBarIconBrightness: navigationBarIconBrightness,
      ),
    );
  }

  /// Wrapper widget for full screen content with custom top padding
  static Widget wrapWithFullScreen({
    required BuildContext context,
    required Widget child,
    Color? backgroundColor,
    double additionalTopPadding = 0,
    double additionalBottomPadding = 0,
    bool includeTopPadding = true,
    bool includeBottomPadding = true,
  }) {
    final topPadding = includeTopPadding ? getTopPadding(context) : 0;
    final bottomPadding = includeBottomPadding ? getBottomPadding(context) : 0;

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(
        top: topPadding + additionalTopPadding,
        bottom: bottomPadding + additionalBottomPadding,
      ),
      child: child,
    );
  }
}

/// Extension method for easier access
extension FullScreenExtension on BuildContext {
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get navigationBarHeight => MediaQuery.of(this).padding.bottom;

  EdgeInsets get fullScreenPadding => EdgeInsets.only(
        top: statusBarHeight,
        bottom: navigationBarHeight,
      );
}
