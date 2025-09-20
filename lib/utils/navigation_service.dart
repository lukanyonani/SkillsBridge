import 'package:flutter/material.dart';

/// Mixin to add tab switching functionality to MainNavigationScreen
mixin TabSwitcher {
  void switchToTab(int tabIndex);
}

/// Navigation service to handle tab switching in the main navigation
class NavigationService {
  static TabSwitcher? _mainNavigationState;

  /// Register the main navigation state
  static void registerMainNavigation(TabSwitcher state) {
    _mainNavigationState = state;
    debugPrint('✅ NavigationService: Main navigation state registered');
  }

  /// Unregister the main navigation state
  static void unregisterMainNavigation() {
    _mainNavigationState = null;
    debugPrint('🔄 NavigationService: Main navigation state unregistered');
  }

  /// Navigate to a specific tab in the main navigation
  static void navigateToTab(BuildContext context, int tabIndex) {
    debugPrint('🧭 NavigationService: Attempting to navigate to tab $tabIndex');

    if (_mainNavigationState != null) {
      debugPrint('✅ NavigationService: Using registered main navigation state');
      _mainNavigationState!.switchToTab(tabIndex);
    } else {
      debugPrint(
        '❌ NavigationService: No registered main navigation state, trying to find one',
      );
      // Fallback: try to find the state in the widget tree
      final mainScreen = context.findAncestorStateOfType<State>();
      if (mainScreen != null && mainScreen is TabSwitcher) {
        debugPrint(
          '✅ NavigationService: Found TabSwitcher state in widget tree',
        );
        (mainScreen as TabSwitcher).switchToTab(tabIndex);
      } else {
        debugPrint('❌ NavigationService: Could not find TabSwitcher state');
      }
    }
  }

  /// Navigate to Jobs tab (index 3)
  static void navigateToJobs(BuildContext context) {
    navigateToTab(context, 3);
  }

  /// Navigate to Learning tab (index 1)
  static void navigateToLearning(BuildContext context) {
    navigateToTab(context, 1);
  }

  /// Navigate to Bursaries tab (index 4)
  static void navigateToBursaries(BuildContext context) {
    navigateToTab(context, 4);
  }

  /// Navigate to AI Counsellor tab (index 2)
  static void navigateToCounsellor(BuildContext context) {
    navigateToTab(context, 2);
  }

  /// Navigate to Home tab (index 0)
  static void navigateToHome(BuildContext context) {
    navigateToTab(context, 0);
  }
}
