import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
part 'expense.g.dart';

final formatter = DateFormat.yMd();

const uuid = Uuid();

@HiveType(typeId: 0)
enum Category {
  @HiveField(0)
  food,
  @HiveField(1)
  travel,
  @HiveField(2)
  leisure,
  @HiveField(3)
  work
}

const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.movie,
  Category.work: Icons.work
};

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  Category category;

  @HiveField(4)
  String id;

  Expense(
      {required this.title,
      required this.amount,
      required this.date,
      required this.category})
      : id = uuid.v4();

  String get formattedDate {
    return formatter.format(date);
  }
}

@HiveType(typeId: 2)
class ExpenseLimit extends HiveObject{
  @HiveField(0)
  double limitAmount;
  ExpenseLimit({required this.limitAmount});
}

class ExpenseBucket {
  ExpenseBucket({required this.category, required this.expenses});

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;

    for (final expense in expenses) {
      sum += expense.amount;
    }

    return sum;
  }
}
