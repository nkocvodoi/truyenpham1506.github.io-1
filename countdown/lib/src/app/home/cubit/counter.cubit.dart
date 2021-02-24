import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:jlpt_testdate_countdown/src/models/date/date.dart';
import 'package:jlpt_testdate_countdown/src/repositories/counter.repository.dart';
import 'package:jlpt_testdate_countdown/src/resources/data.dart';

part 'counter.state.dart';

class CounterCubit extends Cubit<CounterState> {
  Timer timer;
  final dateRepository = FakeDateRepository();

  CounterCubit() : super(CounterInitial()) {
    loadCountTime();
  }

  void loadCountTime() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateCount dateCount = dateRepository.fetchTime(DataConfig.testDate);
      emit(OneSecondPassed(dateCount));
    });
  }

}

class DetailCountdownData{
  int daysLeft;
  int hoursLeft;
  int minutesLeft;
  int secondsLeft;

  DetailCountdownData.fromDateCount(DateCount dateCount) {
    daysLeft = dateCount.timeLeft.inDays;
    hoursLeft = dateCount.timeLeft.inHours - (daysLeft * 24);
    minutesLeft = dateCount.timeLeft.inMinutes - (daysLeft * 24 * 60) - (hoursLeft * 60);
    secondsLeft = dateCount.timeLeft.inSeconds - (daysLeft * 24 * 60 * 60) - (hoursLeft * 60 * 60) - (minutesLeft * 60);
  }
}
