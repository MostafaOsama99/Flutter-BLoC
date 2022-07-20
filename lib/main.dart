import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

import 'bloc/bloc_actions.dart';
import 'bloc/person.dart';
import 'bloc/persons_bloc.dart';

extension Log on Object {
  void log() => devtools.log(toString());
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
                      .add(const LoadPersonsAction(url: persons1Url, loader: getPersons)),
                  child: const Text('load json #1')),
              TextButton(
                  onPressed: () => context
                      .read<PersonsBloc>()
                      .add(const LoadPersonsAction(url: persons2Url, loader:
                  getPersons)),
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
