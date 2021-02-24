import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DateCount extends Equatable {
  final Duration timeLeft;
  final DateTime targetDate;

  DateCount({@required this.timeLeft, this.targetDate});

  @override
  List<Object> get props => [timeLeft];
}
