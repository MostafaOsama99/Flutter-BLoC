import 'package:flutter/foundation.dart' show immutable;

@immutable
class Person {
  late final String name;
  late final int age;

  Person.fromJson(Map<String, dynamic> json) {
    age = json['age'];
    name = json['name'];
  }
}