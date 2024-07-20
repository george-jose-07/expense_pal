import 'package:expense_pal/widgets/result_page.dart';
import 'package:flutter/material.dart';
import 'package:expense_pal/widgets/chart/chart.dart';
import 'package:expense_pal/widgets/new_expense.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expense.dart';
import 'expenses_list/expense_list.dart';
import 'package:hive/hive.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpense = [];

  getExpenses() async {
    var box = await Hive.openBox<Expense>('hive_box');
    setState(() {
      _registeredExpense = box.values.toList();
    });
  }

  @override
  void initState() {
    getExpenses();
    getExpensesLimit();
    super.initState();
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  void _addExpense(Expense expanse) async {
    var box = await Hive.openBox<Expense>('hive_box');
    setState(() {
      _registeredExpense.add(expanse);
      box.add(expanse);
    });
  }

  void _removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpense.indexOf(expense);
    var box = await Hive.openBox<Expense>('hive_box');
    setState(() {
      _registeredExpense.remove(expense);
      box.deleteAt(expenseIndex);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text("expense deleted"),
        action: SnackBarAction(
          label: "undo",
          onPressed: () async {
            var box = await Hive.openBox<Expense>('hive_box');
            setState(
              () {
                _registeredExpense.insert(expenseIndex, expense);
                box.put(expenseIndex, expense);
              },
            );
          },
        ),
      ),
    );
  }

  double _expenseLimit = 0;
  final _limitController = TextEditingController();

  Future<void> getExpensesLimit() async {
    var box = await Hive.openBox<double>('hive box');
    setState(() {
      _expenseLimit = box.get('limit') ?? 0;
      _limitController.text = _expenseLimit.toString();
    });
  }

  Future<void> updateLimit() async {
    final enteredAmount =
        double.tryParse(_limitController.text) ?? _expenseLimit;
    final box = await Hive.openBox<double>('hive box');
    await box.put('limit', enteredAmount);
    setState(() {
      _expenseLimit = enteredAmount;
    });
    //widget.onUpdateLimit(_expenseLimit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Widget mainContent = const Center(
      child: Text("no expenses found. start adding some."),
    );

    if (_registeredExpense.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpense,
        onRemoveExpense: _removeExpense,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ExpensePal",
          style: TextStyle(fontSize: 30),
        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 3000.ms,
              delay: 1000.ms,
              color: Theme.of(context).colorScheme.primary,
            ),
        actions: [
          IconButton(
            onPressed: () {
              final keyBoardSpace = MediaQuery.of(context).viewInsets.bottom;
              showModalBottomSheet(
                useSafeArea: true,
                isScrollControlled: true,
                enableDrag: true,
                elevation: 100,
                showDragHandle: true,
                context: context,
                builder: (ctx) => SingleChildScrollView(
                  child: SizedBox(
                    height: double.maxFinite,
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(16, 48, 16, keyBoardSpace + 16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _limitController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              label: Text("Enter the limit"),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                onPressed: updateLimit,
                                child: const Text("save"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
          IconButton(
            onPressed: () {
              _openAddExpenseOverlay();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: width < 600
          ? Column(
              children: [
                CarouselSlider(
                  items: [
                    ResultPage(
                      registeredExpense: _registeredExpense,
                      expenseLimit: _expenseLimit,
                    ),
                    Chart(expenses: _registeredExpense),
                  ],
                  options: CarouselOptions(
                    height: 250.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayCurve: Curves.easeInOut,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    viewportFraction: 1,
                  ),
                ),
                Expanded(
                  child: mainContent,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: CarouselSlider(
                      items: [
                        ResultPage(
                          registeredExpense: _registeredExpense,
                          expenseLimit: _expenseLimit,
                        ),
                        Chart(expenses: _registeredExpense),
                      ],
                      options: CarouselOptions(
                        height: 250.0,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        autoPlayInterval: const Duration(seconds: 5),
                        autoPlayCurve: Curves.easeInOut,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        viewportFraction: 1,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: mainContent,
                ),
              ],
            ),
    );
  }
}
