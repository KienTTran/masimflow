import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class Marker extends CustomPainter {
  late double radius;
  late double dy;
  late bool selected;
  late List<double> xs;
  late double y;
  late double defaultY;
  late double lowerX;
  late double upperX;
  late DateTime startingDate;
  late DateTime endingDate;
  late List<DateTime> dates;
  late double canvasWidth;
  late String id;
  late Color color;
  late Color invertColor;
  late Paint painter;
  late int index;
  late double initialDy;

  Marker(this.startingDate, this.endingDate, this.y, this.radius, this.dy, this.selected) {
    xs = [];
    defaultY = 0;
    dy = 50;
    initialDy = dy;
    selected = false;
    y = 0;
    radius = 20;
    canvasWidth = 0;
    canvasWidth = 0;
    lowerX = 0;
    upperX = 0;
    id = Uuid().v4();
    // date = startingDate;
    dates = [];
    setStartingDate(startingDate);
    setEndingDate(endingDate);
    // setDate(startingDate);
    updateXs();
    color = Colors.black;
    invertColor = Colors.blue;
    updatePainter();
    index = 0;
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

  void checkDates(List<DateTime> dates) {
    this.dates = dates;
    this.dates = this.dates.map((date) {
      if (date.isBefore(startingDate)) {
        return startingDate;
      }
      if (date.isAfter(endingDate)) {
        return endingDate;
      }
      return date;
    }).toList();
  }

  void setDates(List<DateTime> dates) {
    checkDates(dates);
    for(int i = 0; i < dates.length; i++){
      double totalDays = endingDate.difference(startingDate).inDays.toDouble();
      double daysSinceStart = this.dates[i].difference(startingDate).inDays.toDouble();
      xs.add(daysSinceStart / totalDays);
    }
  }

  void updateXs() {
    xs.clear();
    for(int i = 0; i < dates.length; i++){
      double totalDays = endingDate.difference(startingDate).inDays.toDouble();
      double daysSinceStart = this.dates[i].difference(startingDate).inDays.toDouble();
      xs.add(daysSinceStart / totalDays);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void updateIndex(int totalMarkers, int index) {
    this.index = index;
    if(initialDy < 0){
      dy = (index/totalMarkers) * initialDy;
    }
  }

  double getSmallestX() {
    if(xs.isNotEmpty) {
      return xs.reduce((a, b) => a < b ? a : b);
    }
    return 0;
  }
}

