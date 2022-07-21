import 'package:block/bloc/bloc_actions.dart';
import 'package:block/bloc/person.dart';
import 'package:block/bloc/persons_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

const mockedPersons1 = [
  Person(name: 'Mostafa', age: 20),
  Person(name: 'Ahmed', age: 30),
];
const mockedPersons2 = [
  Person(name: 'Mostafa', age: 20),
  Person(name: 'Ahmed', age: 30),
];

// here we skip getting the data from the local server
// we don't user PersonsLoader anymore
// since we are interested into our BLoC testing
Future<Iterable<Person>> getMockedPersons1(_) => Future.value(mockedPersons1);

Future<Iterable<Person>> getMockedPersons2(_) => Future.value(mockedPersons2);

void main() {
  /// the test needs to cover as many lines of writing code as possible
  /// it's preferred to validate ur test functions by giving them wrong values and watch them fail

  /// group of multiple tests runs together
  group('Testing bloc', () {
    // write our test

    // this cannot be final since it will be change per each test
    late PersonsBloc bloc;

    /// this function runs before EVERY test in order to initialize all
    /// required data before test begin
    setUp(() => bloc = PersonsBloc());

    /// testing the initial state of the bloc
    blocTest<PersonsBloc, FetchResult?>(
      'Test initial state',

      // use our initialized bloc
      build: () => bloc,

      /// verify returns dynamic, and we should return expect in order to validate our test
      verify: (bloc) => expect(bloc.state, null),
    );

    // fetch mock data (persons1) and compare it with FetchResult
    blocTest<PersonsBloc, FetchResult?>('Mock retrieving persons from the firs iterable',
        build: () => bloc,
        // actions
        act: (bloc) {
          // first one should be fetch from the loader
          bloc.add(const LoadPersonsAction(loader: getMockedPersons1, url: 'mocked_url_1'));
          // second one should be fetched from the cash
          bloc.add(const LoadPersonsAction(loader: getMockedPersons1, url: 'mocked_url_1'));
        },
    expect: ()=> [
      const FetchResult(isRetrievedFromCash: false, persons: mockedPersons1),
      const FetchResult(isRetrievedFromCash: true, persons: mockedPersons1),
    ]
    );

    // fetch mock data (persons2) and compare it with FetchResult
    blocTest<PersonsBloc, FetchResult?>('Mock retrieving persons from the second iterable',
        build: () => bloc,
        // actions
        act: (bloc) {
          // first one should be fetch from the loader
          bloc.add(const LoadPersonsAction(loader: getMockedPersons2, url: 'mocked_url_2'));
          // second one should be fetched from the cash
          bloc.add(const LoadPersonsAction(loader: getMockedPersons2, url: 'mocked_url_2'));
        },
    expect: ()=> [
      const FetchResult(isRetrievedFromCash: false, persons: mockedPersons2),
      const FetchResult(isRetrievedFromCash: true, persons: mockedPersons2),
    ]
    );


  });
}














