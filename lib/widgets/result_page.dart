import 'package:flutter/material.dart';

import '../models/expense.dart';

class ResultPage extends StatefulWidget {
  const ResultPage(
      {super.key, required this.registeredExpense, required this.expenseLimit});
  final List<Expense> registeredExpense;
  final double expenseLimit;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<ExpenseBucket> get buckets {
    return [
      ExpenseBucket.forCategory(widget.registeredExpense, Category.food),
      ExpenseBucket.forCategory(widget.registeredExpense, Category.leisure),
      ExpenseBucket.forCategory(widget.registeredExpense, Category.travel),
      ExpenseBucket.forCategory(widget.registeredExpense, Category.work),
    ];
  }

  double get totalExpenses {
    double sum = 0;
    for (final expense in widget.registeredExpense) {
      sum += expense.amount;
    }
    return sum;
  }

  double get balance {
    double balanceAmount = 0;
    balanceAmount = widget.expenseLimit - totalExpenses;
    return balanceAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.35),
            Theme.of(context).colorScheme.primary.withOpacity(0.1)
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            '₹ ${balance.toString()}',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    "Total Limit",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    '₹ ${widget.expenseLimit.toString()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,fontSize: 20
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Text(
                    "Total Expense",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    '₹ $totalExpenses',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,fontSize: 20
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          totalExpenses > widget.expenseLimit
              ? const Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 15,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      'limit is exceeded',
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  ],
                )
              : const Text(''),
        ],
      ),
    );
  }
}
