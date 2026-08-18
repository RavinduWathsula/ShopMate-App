import 'package:go_router/go_router.dart';
import '../presentation/splash_screen.dart';
import '../presentation/onboarding_screen.dart';
import '../presentation/login_screen.dart';
import '../presentation/register_screen.dart';
import '../presentation/home_dashboard_screen.dart';
import '../presentation/supermarket_selection_screen.dart';
import '../presentation/budget_setup_screen.dart';
import '../presentation/shopping_list_screen.dart';
import '../presentation/camera_recognition_screen.dart';
import '../presentation/product_details_screen.dart';
import '../presentation/smart_basket_screen.dart';
import '../presentation/discounts_screen.dart';
import '../presentation/recommendations_screen.dart';
import '../presentation/product_location_screen.dart';
import '../presentation/store_map_screen.dart';
import '../presentation/shopping_summary_screen.dart';
import '../presentation/spending_analytics_screen.dart';
import '../presentation/profile_screen.dart';
import '../presentation/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
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
      path: '/productdetails/:id',
      builder: (context, state) => ProductDetailsScreen(productId: state.pathParameters['id']!),
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
      builder: (context, state) => const RecommendationsScreen(),
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
  ],
);
