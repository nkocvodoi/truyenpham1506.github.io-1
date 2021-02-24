part of 'counter.cubit.dart';

@immutable
abstract class CounterState extends Equatable {
  const CounterState();
}

class CounterInitial extends CounterState {
  const CounterInitial();

  @override
  List<Object> get props => [];
}

class CounterLoading extends CounterState {
  const CounterLoading();

  @override
  List<Object> get props => [];
}

class OneSecondPassed extends CounterState {
  final DateCount dateCount;

  OneSecondPassed(this.dateCount);

  @override
  List<Object> get props => [dateCount];
}
