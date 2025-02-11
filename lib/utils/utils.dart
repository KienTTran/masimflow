import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Utils {
  /// Returns a random date between [start] and [end] formatted as specified by [format].
  static String getRandomDateInRange(DateTime start, DateTime end, String format) {
    // Convert the start and end dates to milliseconds since epoch.
    int startMillis = start.millisecondsSinceEpoch;
    int endMillis = end.millisecondsSinceEpoch;

    // Compute the difference.
    int diff = endMillis - startMillis;

    // Generate a random offset using nextDouble.
    int randomOffset = (Random().nextDouble() * diff).floor();

    // Create the random DateTime.
    DateTime randomDate = DateTime.fromMillisecondsSinceEpoch(startMillis + randomOffset);

    // Format the date using the provided format string.
    return DateFormat(format).format(randomDate);
  }

  static String getFormKeyID(String id, String label){
    return '$id#${label.replaceAll(' ', '_')}';
  }

  static getControllerKeyLabel(String key){
    //find label position in key, extract from 'date' to end
    List<String> keyParts = key.split('#');
    if(keyParts.last.contains('date')){
      return keyParts.last.replaceAll('_', '#');
    }
    return keyParts.last.replaceAll('_', ' ');
  }

  // static (String newID, Map<String,TextEditingController>) getNewFormControllers(String oldID, Map<String, TextEditingController> controllers){
  //   String newID = Uuid().v4();
  //   Map<String, TextEditingController> newControllers = {};
  //   for(int i = 0; i < controllers.length; i++){
  //     String oldControllerKey = controllers.keys.elementAt(i);
  //     String newControllerKey = oldControllerKey.replaceAll(oldID, newID);
  //     newControllers[newControllerKey] = TextEditingController(text: controllers[oldControllerKey]?.text);
  //   }
  //   return (newID,newControllers);
  // }

  static (String, Map<String, TextEditingController>) getNewFormControllers(
      String oldId, Map<String, TextEditingController> oldControllers) {
    final newId = const Uuid().v4();
    final newControllers = <String, TextEditingController>{};

    for (var entry in oldControllers.entries) {
      final newKey = entry.key.replaceAll(oldId, newId);
      newControllers[newKey] = TextEditingController(text: entry.value.text);
    }
    return (newId, newControllers);
  }

  static DateTime getEarliestDate(List<DateTime> dates){
    if(dates.length == 1){
      return dates.first;
    }
    return dates.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  static String getEarliestDateString(List<DateTime> dates){
    if(dates.length == 1){
      return DateFormat('yyyy/MM/dd').format(dates.first);
    }
    return DateFormat('yyyy/MM/dd').format(dates.reduce((a, b) => a.isBefore(b) ? a : b));
  }

  static String getControllerFirstDateKey(Map<String, TextEditingController> controllers){
    List<DateTime> dates = [];
    for (var key in controllers.keys) {
      if (key.contains('date')) {
        dates.add(DateFormat('yyyy/MM/dd').parse(controllers[key]!.text));
      }
    }
    return DateFormat('yyyy/MM/dd').format(dates.reduce((a, b) => a.isBefore(b) ? a : b));
  }

  static Color generateColorFromString(String str) {
    int hash = str.hashCode;
    return Color.fromARGB(
      255,
      (hash & 0xFF0000) >> 16,
      (hash & 0x00FF00) >> 8,
      hash & 0x0000FF,
    );
  }

  static Color invertColor(Color color) {
    return Color.from(
      alpha: color.a,
      red: 255 - color.r,
      green: 255 - color.g,
      blue: 255 - color.b,
    );
  }

  static String removeExtraChars(String value){
    if(value.contains('[') && value.contains(']')){
      value = value.replaceAll('[', '');
      value = value.replaceAll(']', '');
    }
    if(value.contains(' ')){
      value = value.replaceAll(' ', '');
    }
    return value;
  }
}
