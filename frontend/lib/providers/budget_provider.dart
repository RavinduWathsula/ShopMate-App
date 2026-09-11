import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetState {
  final double budget;
  final double spent;

  const BudgetState({
    required this.budget,
    required this.spent,
  });

  BudgetState copyWith({
    double? budget,
    double? spent,
  }) {
    return BudgetState(
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier() : super(const BudgetState(budget: 4000.0, spent: 1650.0)) {
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBudget = prefs.getDouble('user_budget');
    if (savedBudget != null) {
      state = state.copyWith(budget: savedBudget);
    }
  }

  Future<void> setBudget(double budget) async {
    state = state.copyWith(budget: budget);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_budget', budget);
  }

  void setSpent(double spent) {
    state = state.copyWith(spent: spent);
  }
  
  void addSpent(double amount) {
    state = state.copyWith(spent: state.spent + amount);
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier();
});

