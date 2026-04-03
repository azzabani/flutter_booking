import 'package:flutter/material.dart';

class ResourceProvider extends ChangeNotifier {

  List resources = [];

  void addResource(String resource) {
    resources.add(resource);
    notifyListeners();
  }

}