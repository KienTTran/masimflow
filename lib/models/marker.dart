import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class Marker extends CustomPainter {
  final double radius;
  final double dy;
  late bool selected;
  late double x;
  late double y;
  late double defaultY;
  late double lowerX;
  late double upperX;
  late DateTime startingDate;
  late DateTime endingDate;
  late DateTime date;
  late double canvasWidth;
  late String id;
  late Color color;
  late Color invertColor;
  late Paint painter;

  Marker(this.startingDate, this.endingDate, this.y, this.radius, this.dy, this.selected) {
    canvasWidth = 0;
    lowerX = 0;
    upperX = 0;
    id = Uuid().v4();
    setStartingDate(startingDate);
    setEndingDate(endingDate);
    setDate(startingDate);
    updateX();
    color = Colors.black;
    invertColor = Colors.blue;
    updatePainter();
  }

  void updatePainter(){
    painter = selected ?
      (Paint()..color = invertColor..style = PaintingStyle.fill .. strokeWidth = 4)
    : (Paint()..color = color..style = PaintingStyle.fill);
  }

  void setStartingDate(DateTime startingDate) {
    this.startingDate = startingDate;
  }

  void setEndingDate(DateTime endingDate) {
    this.endingDate = endingDate;
  }

  void checkDate(DateTime date) {
    this.date = date;
    if (this.date.isBefore(startingDate)) {
      this.date = startingDate;
    }
    if (this.date.isAfter(endingDate)) {
      this.date = endingDate;
    }
  }

  void setDate(DateTime date) {
    checkDate(date);
    double totalDays = endingDate.difference(startingDate).inDays.toDouble();
    double daysSinceStart = date.difference(startingDate).inDays.toDouble();
    x = (daysSinceStart / totalDays);
  }

  DateTime getDate() {
    return date;
  }

  void updateX() {
    double totalDays = endingDate.difference(startingDate).inDays.toDouble();
    double daysSinceStart = date.difference(startingDate).inDays.toDouble();
    x = (daysSinceStart / totalDays);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

