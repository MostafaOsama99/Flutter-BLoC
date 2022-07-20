import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

// when creating a BLoC we need to know what kind of EVENT does this BLoC accept
// and what of a STATE does this BLoC produce
// all BLoCs have multiple events, and produces multiple states

// this to make the events from the same type
@immutable
abstract class LoadAction {
  const LoadAction();
}

enum PersonUrl { persons1, persons2 }

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.persons1:
        return 'http://127.0.0.1:5500/api/persons1.json';
      case PersonUrl.persons2:
        return 'http://127.0.0.1:5500/api/persons2.json';
    }
  }
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) =>
      (index >= 0 && index < length) ? elementAt(index) : null;
}

// getting persons
Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((request) => request.close())
    .then((response) => response.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List)
    .then((list) => list.map((e) => Person.fromJson(e)));

@immutable
class FetchResult {
  final bool isRetrievedFromCash;
  final Iterable<Person> persons;

  const FetchResult({required this.isRetrievedFromCash, required this.persons});

  @override
  String toString() => 'FetchResults:\n\tis Retrieved from cash: '
      '$isRetrievedFromCash\n\tPersons: $persons';
}

@immutable
class LoadPersonsAction implements LoadAction {
  final PersonUrl url;

  const LoadPersonsAction({required this.url});
}

class Person {
  late final String name;
  late final int age;

  Person.fromJson(Map<String, dynamic> json) {
    age = json['age'];
    name = json['name'];
  }
}

// here it comes
class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> _cash = {};

  PersonsBloc() : super(null) {
    on<LoadPersonsAction>((event, emit) async {
      final url = event.url;
      if (_cash[url] != null) {
        emit(FetchResult(isRetrievedFromCash: true, persons: _cash[url]!));
      } else {
        final result = await getPersons(url.urlString);
        _cash[url.urlString] = result;
        emit(FetchResult(isRetrievedFromCash: false, persons: result));
      }
    });
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          BlocProvider(create: (_) => PersonsBloc(), child: const MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter BLoC'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: () => context
                      .read<PersonsBloc>()
                      .add(const LoadPersonsAction(url: PersonUrl.persons1)),
                  child: const Text('load json #1')),
              TextButton(
                  onPressed: () => context
                      .read<PersonsBloc>()
                      .add(const LoadPersonsAction(url: PersonUrl.persons1)),
                  child: const Text('load json #2')),
            ],
          ),
          BlocBuilder<PersonsBloc, FetchResult?>(
              buildWhen: (previousState, currentState) {
            return previousState?.persons != currentState?.persons;
          }, builder: (_, state) {
            state?.log();

            if (state == null) {
              return const SizedBox(
                  height: 100, child: Center(child: Text('Nothing here')));
            }
            return Expanded(
                child: ListView.builder(
                    itemBuilder: (_, index) => ListTile(
                          title: Text(state.persons[index]!.name),
                          subtitle: Text(state.persons[index]!.age.toString()),
                        )));
          })
        ],
      ),
    );
  }
}
