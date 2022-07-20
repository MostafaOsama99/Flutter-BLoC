import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'bloc_actions.dart';
import 'person.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection(other.toSet()).length == length;
}

@immutable
class FetchResult {
  final bool isRetrievedFromCash;
  final Iterable<Person> persons;

  const FetchResult({required this.isRetrievedFromCash, required this.persons});

  @override
  String toString() => 'FetchResults:\n\tis Retrieved from cash: '
      '$isRetrievedFromCash\n\tPersons: $persons';

  @override
  bool operator ==(covariant FetchResult other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetrievedFromCash == other.isRetrievedFromCash;

  @override
  int get hashCode => Object.hash(persons, isRetrievedFromCash);

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
        final result = await event.loader(url);
        _cash[url] = result;
        emit(FetchResult(isRetrievedFromCash: false, persons: result));
      }
    });
  }
}
