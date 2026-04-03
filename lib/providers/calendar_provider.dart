import 'package:flutter/material.dart';

class CalendarProvider extends ChangeNotifier {

  DateTime selectedDate = DateTime.now();

  void changeDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

}