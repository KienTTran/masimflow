
import 'package:flutter/material.dart';
import 'package:masimflow/models/events/event.dart';
import 'package:masimflow/models/markers/marker.dart';
import 'package:masimflow/models/markers/strategy_marker.dart';
import 'package:masimflow/utils/utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

class EventMarker extends Marker {
  late List<String> yamlKeys;
  late dynamic data;
  late dynamic yamlValue;
  late Event event;
  late StrategyMarker strategyMarker;

  @override
  bool shouldRepaint(EventMarker oldDelegate) => true;

  EventMarker(this.event, startingDate, DateTime endingDate, double y, double radius, double dy, bool selected)
      : super(startingDate, endingDate, y, radius, dy, selected){
    this.y = y;
    this.radius = radius;
    this.dy = dy;
    this.initialDy = dy;
    this.selected = selected;
    canvasWidth = 0;
    lowerX = 0;
    upperX = 0;
    setStartingDate(startingDate);
    setEndingDate(endingDate);
    // setDate(Utils.getEarliestDate(event.dates()));
    setDates(event.dates());
    updateXs();
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

  @override
  void paint(Canvas canvas, Size size) {
    updatePainter();
    if(y == -1) {
      y = defaultY;
    }
    canvasWidth = upperX - lowerX;
    for(int i = 0; i < xs.length; i++){
      Utils.drawMarker(lowerX + xs[i]*canvasWidth, y, dy, radius,
          '${DateFormat('yyyy/MM/dd').format(event.dates()[i])}\n${Utils.getCapitalizedWords(event.name)}',
          painter, canvas, size, color: color, maxLines: 2);
    }
  }
}