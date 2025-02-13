import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

class Utils {

  static void drawMarker(double x, double y, double dy, double radius, String text, Paint paint, Canvas canvas, Size size, {maxLines = 1, color = Colors.black}) {
    // canvas.drawLine(Offset(x, y - radius), Offset(x, y - dy + radius), paint);
    // canvas.drawCircle(Offset(x, y), radius, paint);
    // canvas.drawCircle(Offset(x, y - dy), radius, paint);
    canvas.drawLine(Offset(x, y), Offset(x, y - dy), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y), width: radius, height: radius), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y-dy), width: radius, height: radius), paint);
    drawText(x, y - dy, dy < 0 ? -(radius*2) : radius*4, text, canvas, size, color: color, maxLines: maxLines);
  }

  static void drawText(double x, double y, double dy, String text, Canvas canvas, Size size,{int maxLines = 1, color = Colors.black, maxWidth = 150}) {
    var textStyle = TextStyle(
      color: color,
      fontSize: 16,
      overflow: TextOverflow.ellipsis,
      // background: Paint()
      //   ..color = color
      //   ..strokeWidth = 2
      //   ..strokeJoin = StrokeJoin.round
      //   ..strokeCap = StrokeCap.round
      //   ..style = PaintingStyle.fill,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      ellipsis: '...',
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: maxWidth,
    );
    // textPainter.paint(canvas,
    //     Offset((size.width - textPainter.width) / 2,(size.height - textPainter.height) / 2));
    textPainter.paint(canvas, Offset(x-textPainter.width/2, y - dy));
    // textPainter.paint(canvas, Offset(x, y - dy));
  }

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
      return getCapitalizedWords(keyParts.last.replaceAll('_', '#'));
    }
    return getCapitalizedWords(keyParts.last.replaceAll('_', ' '));
  }

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

  static List<List<double>> extractDoubleMatrix(String input) {
    return input
        .replaceAll('[[', '')
        .replaceAll(']]', '')
        .split('], [') // Splitting by '], [' to separate locations
        .map((row) => row
        .split(',')
        .map((value) => double.tryParse(value.trim()) ?? 0.0)
        .toList())
        .toList();
  }

  static List<double> extractDoubleList(String input) {
    return input
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((value) => double.tryParse(value.trim()) ?? 0.0)
        .toList();
  }


  static List<List<int>> extractIntegerMatrix(String input) {
    return input
        .replaceAll('[[', '')
        .replaceAll(']]', '')
        .split('], [') // Splitting by '], [' to separate locations
        .map((row) => row
        .split(',')
        .map((value) => int.tryParse(value.trim()) ?? 0)
        .toList())
        .toList();
  }

  static List<int> extractIntegerList(String input) {
    return input
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((value) => int.tryParse(value.trim()) ?? 0)
        .toList();
  }

  static String getCapitalizedString(String input){
    return input[0].toUpperCase() + input.substring(1);
  }

  static String getCapitalizedWords(String input){
    return input.split(' ').map((word) => getCapitalizedString(word)).join(' ')
        .replaceAll('_', ' ').replaceAll('#', ' ');
  }
}
