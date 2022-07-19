import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'dart:math' as math show Random;


const names = ['Mostafa', 'Medo', 'boody'];

/// get random element extension
extension RandomElement<T> on Iterable<T>{
  T getRandomElement() => elementAt(math.Random().nextInt(length));
}

// creating Cubit
// cubit and BLoC needs to know which type of State do i managing?
// that's why we give it a type

// Cubit sets on top of Steams and StreamController, and they are very simple to use
// BLoC sets on top of Cubit
// BLoC could produce many states per event however redux produces only one
// state per event

class NamesCubit extends Cubit<String?> {
  /// Cubit and BLoC requires an initial state
  NamesCubit() : super(null);

  void pickRandomName() {
    /// emit used to change the state
    emit(names.getRandomElement());
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late final NamesCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = NamesCubit();
  }

  @override
  void dispose() {
    super.dispose();
    cubit.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter BLoC'),
      ),


      // as cubit state changes we need to update our home page as well
      // so we use stream builder
      body: StreamBuilder<String?>(
          stream: cubit.stream,
          builder: (context, snapshot) {
            final button = TextButton(onPressed: () => cubit.pickRandomName(),
                child: const Text('Pick a random name'));

            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return button;
              case ConnectionState.waiting:
                return button;
              case ConnectionState.active:
                return Column(
                  children: [
                    Text(snapshot.data ?? 'empty'),
                    button
                  ],
                );
              case ConnectionState.done:
                return const SizedBox();
            }
          }
      ),
    );
  }
}
