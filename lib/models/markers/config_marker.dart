
import 'package:flutter/material.dart';
import 'package:masimflow/models/configs/config.dart';
import 'package:masimflow/models/markers/marker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

import '../../utils/utils.dart';

class ConfigMarker extends Marker {
  late DateTime date;
  late Config config;
  late bool isStart;
  late bool isEnd;

  @override
  bool shouldRepaint(ConfigMarker oldDelegate) => true;

  ConfigMarker(startingDate, DateTime endingDate, this.config, double y, double radius, double dy,
      this.isStart, this.isEnd, bool selected)
      : super(startingDate, endingDate, y, radius, dy, selected){
    this.y = y;
    this.radius = radius;
    this.dy = dy;
    this.selected = selected;
    canvasWidth = 0;
    lowerX = 0;
    upperX = 0;
    setStartingDate(startingDate);
    setEndingDate(endingDate);
    setDate(config.date);
    updateX();
  }

  void checkDate(DateTime date){
    if(isStart){
      startingDate = date;
      this.date = date;
    }
    else if(isEnd){
      endingDate = date;
      this.date = date;
    }
    else {
      this.date = date;
      if (this.date.isBefore(startingDate)) {
        this.date = startingDate;
        config.controllers['date']?.text = DateFormat('yyyy/MM/dd').format(date);
      }
      if (this.date.isAfter(endingDate)) {
        this.date = endingDate;
        config.controllers['date']?.text = DateFormat('yyyy/MM/dd').format(date);
      }
    }
  }

  void setDate(DateTime date) {
    checkDate(date);
    double totalDays = endingDate.difference(startingDate).inDays.toDouble();
    double daysSinceStart = this.date.difference(startingDate).inDays.toDouble();
    xs.add(daysSinceStart / totalDays);
  }

  void updateX() {
    // print('updateX name: ${config.name}');
    // print('updateXs startingDate: $startingDate');
    // print('updateXs endingDate: $endingDate');
    xs.clear();
    double totalDays = endingDate.difference(startingDate).inDays.toDouble();
    double daysSinceStart = date.difference(startingDate).inDays.toDouble();
    xs.add(daysSinceStart / totalDays);
    // print('xs: $xs');
  }

  @override
  void paint(Canvas canvas, Size size) {
    updatePainter();
    if(y == -1) {
      y = defaultY;
    }
    canvasWidth = upperX - lowerX;
   Utils.drawMarker(lowerX + xs.first*canvasWidth, y, dy, radius,
       '${DateFormat('yyyy/MM/dd').format(config.date)}\n${Utils.getCapitalizedWords(config.name)}',
       painter,canvas,size, maxLines: 2);
  }
}