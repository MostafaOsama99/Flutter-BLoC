import 'package:flutter/foundation.dart' show immutable;

import 'person.dart';

const persons1Url = 'http://127.0.0.1:5500/api/persons1.json';
const persons2Url = 'http://127.0.0.1:5500/api/persons2.json';


typedef PersonsLoader = Future<Iterable<Person>> Function (String url);

// when creating a BLoC we need to know what kind of EVENT does this BLoC accept
// and what of a STATE does this BLoC produce
// all BLoCs have multiple events, and produces multiple states

// this to make the events from the same type
@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction implements LoadAction {
  final String url;
  final PersonsLoader loader;

  const LoadPersonsAction({required this.loader, required this.url});
}