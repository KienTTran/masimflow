import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:masimflow/models/events/event.dart';
import 'package:masimflow/models/marker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

import '../utils/utils.dart';

class EventMarker extends Marker {
  final double radius;
  final double dy;
  final String text;
  late bool selected;

  late double x;
  late double y;
  late double defaultY;
  late List<String> yamlKeys;
  late dynamic data;
  late dynamic yamlValue;
  late double lowerX;
  late double upperX;
  late DateTime startingDate;
  late DateTime endingDate;
  late DateTime date;
  late double canvasWidth;
  late String id;
  late Event event;

  @override
  bool shouldRepaint(EventMarker oldDelegate) => true;

  EventMarker(this.event, this.startingDate, this.endingDate, this.y, this.radius, this.dy, this.text, this.selected)
      : super(startingDate, endingDate, y, radius, dy, selected){
    canvasWidth = 0;
    lowerX = 0;
    upperX = 0;
    id = Uuid().v4();
    setStartingDate(startingDate);
    setEndingDate(endingDate);
    setDate(Utils.getEarliestDate(event.dates()));
    updateX();
    // print('EventMarker event name: ${event.name} ${this.x}');
    color = Utils.generateColorFromString(event.name);
  }

  void setYamlNodeKeys(List<String> yamlKeys){
    this.yamlKeys = yamlKeys;
  }

  List<String> getYamlNodeKeys(){
    return yamlKeys;
  }

  String getYamlKey(){
    return yamlKeys.last;
  }

  void setYamlValue(dynamic yamlValue){
    this.yamlValue = yamlValue;
  }

  String getYamlValue(){
    return yamlValue.toString();
  }

  void setValue(dynamic data){
    this.data = data;
  }

  String getData(){
    return data;
  }

  void setStartingDate(DateTime startingDate){
    this.startingDate = startingDate;
  }

  void setEndingDate(DateTime endingDate){
    this.endingDate = endingDate;
  }

  void checkDate(DateTime date){
    this.date = date;
    if (this.date.isBefore(startingDate)) {
      this.date = startingDate;
    }
    if (this.date.isAfter(endingDate)) {
      this.date = endingDate;
    }
  }

  void setDate(DateTime date){
    checkDate(date);
    // print('EventMarker setDate startingDate: ${startingDate} endingDate: ${endingDate} date: ${date}');
    // print('setDate ${DateFormat('yyyy/MM/dd').format(startingDate)} ${DateFormat('yyyy/MM/dd').format(endingDate)} ${DateFormat('yyyy/MM/dd').format(date)}');
    double totalDays = endingDate.difference(startingDate).inDays.toDouble();
    double daysSinceStart = this.date.difference(startingDate).inDays.toDouble();
    x = (daysSinceStart / totalDays); // Scale to canvas width
  }

  DateTime getDate(){
    return date;
  }

  void updateX(){
    // print('updateX $text ${DateFormat('yyyy/MM/dd').format(startingDate)} ${DateFormat('yyyy/MM/dd').format(endingDate)} ${DateFormat('yyyy/MM/dd').format(date)}');
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
    drawEventMarker(lowerX + x*canvasWidth, y, dy, radius, text,painter,canvas);
  }

  void drawEventMarker(double x, double y, double dy, double radius, String text, Paint paint, Canvas canvas) {
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