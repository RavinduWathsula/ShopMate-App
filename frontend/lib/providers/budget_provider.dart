import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetNotifier extends StateNotifier<double> {
  BudgetNotifier() : super(0.0);

  void setBudget(double budget) {
    state = budget;
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, double>((ref) {
  return BudgetNotifier();
});

