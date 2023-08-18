// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as https;

void main() {
  runApp(ProviderScope(
      child: MaterialApp(
    home: MyApp(),
  )));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});
  List<int> numbers = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(streamProvider).when(
          data: (data) {
            numbers.add(data);
            return Scaffold(
                body: Center(
              child: ListView.builder(
                itemCount: numbers.length,
                itemBuilder: (context, index) {
                  return Text(numbers[index].toString());
                },
              ),
            ));
          },
          error: (error, stackTrace) => Center(
            child: Text(
              error.toString(),
            ),
          ),
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
        );
  }
}

final streamProvider = StreamProvider((ref) async* {
  for (var i = 0; i < 20; i++) {
    yield (i);
    await Future.delayed(
      Duration(seconds: 1),
    );
  }
});

final getUserProvider = FutureProvider((ref) {
  final url = 'https://jsonplaceholder.typicode.com/users/1';
  return https.get(Uri.parse(url)).then((value) => User.fromJson(value.body));
});

class User {
  final String name;
  final String email;
  User({
    required this.name,
    required this.email,
  });

  User copyWith({
    String? name,
    String? email,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'User(name: $name, email: $email)';

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.name == name && other.email == email;
  }

  @override
  int get hashCode => name.hashCode ^ email.hashCode;
}
