import 'package:go_router/go_router.dart';

import '../../presentation/auth/splash_screen.dart';
import '../../presentation/auth/onboarding_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/home_dashboard_screen.dart';
import '../../presentation/supermarket_selection_screen.dart';
import '../../presentation/budget_setup_screen.dart';
import '../../presentation/shopping_list_screen.dart';
import '../../presentation/camera_recognition_screen.dart';
import '../../presentation/product_details_screen.dart';
import '../../presentation/shopping_cart_screen.dart';
import '../../presentation/smart_basket_screen.dart';
import '../../presentation/discounts_screen.dart';
import '../../presentation/product_location_screen.dart';
import '../../presentation/store_map_screen.dart';
import '../../presentation/shopping_summary_screen.dart';
import '../../presentation/spending_analytics_screen.dart';
import '../../presentation/profile_screen.dart';
import '../../presentation/settings_screen.dart';
import '../../presentation/ai_processing_screen.dart';
import '../../presentation/recognition_result_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/homedashboard',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/supermarketselection',
        builder: (context, state) => const SupermarketSelectionScreen(),
      ),
      GoRoute(
        path: '/budgetsetup',
        builder: (context, state) => const BudgetSetupScreen(),
      ),
      GoRoute(
        path: '/shoppinglist',
        builder: (context, state) => const ShoppingListScreen(),
      ),
      GoRoute(
        path: '/camerarecognition',
        builder: (context, state) => const CameraRecognitionScreen(),
      ),
      GoRoute(
        path: '/productdetails',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ProductDetailsScreen(productData: extra);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const ShoppingCartScreen(),
      ),
      GoRoute(
        path: '/smartbasket',
        builder: (context, state) => const SmartBasketScreen(),
      ),
      GoRoute(
        path: '/discounts',
        builder: (context, state) => const DiscountsScreen(),
      ),
      GoRoute(
        path: '/recommendations',
        builder: (context, state) => const DiscountsScreen(),
      ),
      GoRoute(
        path: '/productlocation',
        builder: (context, state) => const ProductLocationScreen(),
      ),
      GoRoute(
        path: '/storemap',
        builder: (context, state) => const StoreMapScreen(),
      ),
      GoRoute(
        path: '/shoppingsummary',
        builder: (context, state) => const ShoppingSummaryScreen(),
      ),
      GoRoute(
        path: '/spendinganalytics',
        builder: (context, state) => const SpendingAnalyticsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/aiprocessing',
        builder: (context, state) => const AIProcessingScreen(),
      ),
      GoRoute(
        path: '/recognitionresult',
        builder: (context, state) => const RecognitionResultScreen(),
      ),
    ],
  );
}
