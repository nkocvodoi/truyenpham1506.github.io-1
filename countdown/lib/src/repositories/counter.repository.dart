import 'package:jlpt_testdate_countdown/src/models/date/date.dart';

class FakeDateRepository {
  DateCount fetchTime(DateTime testDate) {
    final Duration timeLeft = testDate.difference(DateTime.now());
    return DateCount(timeLeft: timeLeft);
  }
}
