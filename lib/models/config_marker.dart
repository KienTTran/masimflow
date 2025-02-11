import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:masimflow/models/config.dart';
import 'package:masimflow/models/marker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

class ConfigMarker extends Marker {
  final double radius;
  final double dy;
  final bool isStart;
  final bool isEnd;
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
  late Config config;

  @override
  bool shouldRepaint(ConfigMarker oldDelegate) => true;

  ConfigMarker(this.startingDate, this.endingDate, this.config, this.y, this.radius, this.dy, this.isStart, this.isEnd, this.selected)
      : super(startingDate, endingDate, y, radius, dy, selected){
    canvasWidth = 0;
    lowerX = 0;
    upperX = 0;
    id = Uuid().v4();
    setStartingDate(startingDate);
    setEndingDate(endingDate);
    setDate(config.date);
    if(!isStart && !isEnd){
      updateX();
    }
    // print('ConfigMarker config name: ${config.name} ${this.x}');
  }

  void setStartingDate(DateTime startingDate){
    this.startingDate = startingDate;
  }

  void setEndingDate(DateTime endingDate){
    this.endingDate = endingDate;
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
        config.controllers['date']?.text = DateFormat('yyyy/MM/dd').format(this.date);
      }
      if (this.date.isAfter(endingDate)) {
        this.date = endingDate;
        config.controllers['date']?.text = DateFormat('yyyy/MM/dd').format(this.date);
      }
    }
  }

  void setDate(DateTime date){
    checkDate(date);
    // print('ConfigMarker setDate startingDate: ${startingDate} endingDate: ${endingDate} date: ${date}');
    // print('setDate $isStart $isEnd ${DateFormat('yyyy/MM/dd').format(startingDate)} ${DateFormat('yyyy/MM/dd').format(endingDate)} ${DateFormat('yyyy/MM/dd').format(date)}');
    double totalDays = endingDate.difference(startingDate).inDays.toDouble();
    double daysSinceStart = this.date.difference(startingDate).inDays.toDouble();
    x = (daysSinceStart / totalDays); // Scale to canvas width
  }

  DateTime getDate(){
    return date;
  }

  void updateX(){
    // print('updateX ${config.name} ${DateFormat('yyyy/MM/dd').format(startingDate)} ${DateFormat('yyyy/MM/dd').format(endingDate)} ${DateFormat('yyyy/MM/dd').format(date)}');
    double totalDays = endingDate.difference(startingDate).inDays.toDouble();
    double daysSinceStart = date.difference(startingDate).inDays.toDouble();
    x = (daysSinceStart / totalDays); // Scale to canvas width
  }

  @override
  void paint(Canvas canvas, Size size) {
    updatePainter();
    if(y == -1) {
      y = defaultY;
    }
    canvasWidth = upperX - lowerX;
    drawConfigMarker(lowerX + x*canvasWidth, y, dy, radius, config.name,painter,canvas);
  }

  void drawConfigMarker(double x, double y, double dy, double radius, String text, Paint paint, Canvas canvas) {
    canvas.drawLine(Offset(x, y - radius), Offset(x, y - dy + radius), paint);
    canvas.drawCircle(Offset(x, y), radius, paint);
    canvas.drawCircle(Offset(x, y - dy), radius, paint);
    drawText(x, y - dy, dy < 0 ? -(radius*2) : radius*4, text, canvas);
  }

  void drawText(double x, double y, double dy, String text, Canvas canvas) {
    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 16,
      overflow: TextOverflow.ellipsis,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 300,
    );
    textPainter.paint(canvas, Offset(x-text.length*3, y - dy));
  }
}