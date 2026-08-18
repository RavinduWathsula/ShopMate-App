import os

base_path = r"e:\Projects\ShopMate\frontend\lib"
screens = [
    "SplashScreen", "OnboardingScreen", "LoginScreen", "RegisterScreen",
    "HomeDashboardScreen", "SupermarketSelectionScreen", "BudgetSetupScreen",
    "ShoppingListScreen", "CameraRecognitionScreen", "ProductDetailsScreen",
    "SmartBasketScreen", "DiscountsScreen", "RecommendationsScreen",
    "ProductLocationScreen", "StoreMapScreen", "ShoppingSummaryScreen",
    "SpendingAnalyticsScreen", "ProfileScreen", "SettingsScreen"
]

pres_path = os.path.join(base_path, "presentation")
os.makedirs(pres_path, exist_ok=True)

imports = []
routes = []

for s in screens:
    # Convert PascalCase to snake_case for filename
    filename = "".join(['_'+c.lower() if c.isupper() else c for c in s]).lstrip('_') + ".dart"
    filepath = os.path.join(pres_path, filename)
    with open(filepath, "w") as f:
        f.write(f"""import 'package:flutter/material.dart';

class {s} extends StatelessWidget {{
  const {s}({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(title: const Text('{s}')),
      body: const Center(child: Text('{s} Placeholder')),
    );
  }}
}}
""")
    imports.append(f"import '../presentation/{filename}';")
    route_name = "/" + s.replace("Screen", "").lower()
    if s == "SplashScreen":
        route_name = "/"
    routes.append(f"""    GoRoute(
      path: '{route_name}',
      builder: (context, state) => const {s}(),
    ),""")

# Create router.dart
router_path = os.path.join(base_path, "routing", "router.dart")
os.makedirs(os.path.dirname(router_path), exist_ok=True)

with open(router_path, "w") as f:
    f.write(f"""import 'package:go_router/go_router.dart';
{chr(10).join(imports)}

final router = GoRouter(
  initialLocation: '/',
  routes: [
{chr(10).join(routes)}
  ],
);
""")

print("Generated screens and router")
