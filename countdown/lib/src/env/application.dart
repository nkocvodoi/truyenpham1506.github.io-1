import 'package:jlpt_testdate_countdown/src/utils/shared_preferences.dart';

// ignore: constant_identifier_names
enum ENV { PRODUCTION, DEV }

class Application {
  static ENV env = ENV.DEV;
  static SpUtil sharePreference;
  static bool pageIsOpen = false;

  // static API api;

  Map<String, String> get config {
    if (Application.env == ENV.PRODUCTION) {
      return {};
    }
    if (Application.env == ENV.DEV) {
      return {};
    }
    return {};
  }
}
