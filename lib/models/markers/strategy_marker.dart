import 'package:flutter/material.dart';
import 'package:masimflow/models/markers/marker.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/models/strategy_parameters.dart';
import 'package:masimflow/models/therapy.dart';
import '../../utils/utils.dart';
import '../drug.dart';

class StrategyMarker extends Marker {
  final bool isStart;
  final bool isEnd;
  final StrategyParameters strategyParameters;
  final Map<int, Therapy> therapies;
  final Map<int, Drug> drugs;
  final String text;
  late List<(int, DateTime,double,String)> strategyIdDateXLabelMapList;
  late List<(String, DateTime,double)> labelDateXMapList;

  @override
  bool shouldRepaint(StrategyMarker oldDelegate) => true;

  StrategyMarker(this.strategyParameters, this.therapies, this.drugs,
      this.strategyIdDateXLabelMapList, this.labelDateXMapList, this.text,
      DateTime startingDate, DateTime endingDate, double y, double radius, double dy,
      this.isStart, this.isEnd, bool selected)
      : super(startingDate, endingDate, y, radius, dy, selected){
    this.y = y;
    this.radius = radius;
    this.dy = dy;
    this.selected = selected;
    canvasWidth = 0;
    lowerX = 0;
    upperX = 0;
    // date = strategyIdDateXLabelMapList.first.$1;
    // print('StrategyMarker id: $id');
    setStartingDate(startingDate);
    setEndingDate(endingDate);
    // setDate(date);
    updateX();
  }

  void updateX(){
    strategyIdDateXLabelMapList = strategyIdDateXLabelMapList.map((strategyIdDateXMap) {
      int strategyId = strategyIdDateXMap.$1;
      DateTime date = strategyIdDateXMap.$2;
      double x = (date.difference(startingDate).inDays / endingDate.difference(startingDate).inDays);
      String label = strategyIdDateXMap.$4;
      return (strategyId, date, x, label);
    }).toList();
    labelDateXMapList = labelDateXMapList.map((strategyIdDateXMap) {
      String label = strategyIdDateXMap.$1;
      DateTime date = strategyIdDateXMap.$2;
      double x = (date.difference(startingDate).inDays / endingDate.difference(startingDate).inDays);
      return (label, date, x);
    }).toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    updatePainter();
    if(y == -1) {
      y = defaultY;
    }
    canvasWidth = upperX - lowerX;
    for(var strategyIdDateXMap in strategyIdDateXLabelMapList){
      drawStrategyMarker1(strategyIdDateXMap, y, dy, radius, text, painter, canvas, size);
    }
    for(var labelDateXMap in labelDateXMapList){
      drawStrategyMarker2(labelDateXMap, y, dy, radius, text, painter, canvas, size);
    }
  }

  void drawStrategyMarker1((int,DateTime,double,String) strategyIdDateXLabelMap, double y, double dy, double radius, String text, Paint paint, Canvas canvas, Size size) {
    double x = lowerX + strategyIdDateXLabelMap.$3*canvasWidth;
    canvas.drawLine(Offset(x, y), Offset(x, y - dy), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y), width: radius, height: radius), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y-dy), width: radius, height: radius), paint);
    List<String> therapyNames = [];
    List<int> therapyIds = [];
    String strategyName = '';
    int strategyId = strategyIdDateXLabelMap.$1;
    if(strategyId == -1){
      therapyIds = Utils.getTherapyIndex(strategyParameters,strategyParameters.strategyDb[strategyParameters.initialStrategyId]!);
      strategyName = text;
    }
    else{
      therapyIds = Utils.getTherapyIndex(strategyParameters,strategyParameters.strategyDb[strategyId]!);
      strategyName = strategyParameters.strategyDb[strategyId]!.name;
    }
    for(int therapyId in therapyIds){
      therapyNames.add('${therapies[therapyId]!.name}');
    }
    Utils.drawText(x, y - dy, dy < 0 ? -(radius*2) : radius*4,
        '$strategyName\n${strategyIdDateXLabelMap.$4}\n${therapyNames.toString()}',
        canvas,size, maxWidth: 300, maxLines: 5);
  }

  void drawStrategyMarker2((String,DateTime,double) labelDateXMapList, double y, double dy, double radius, String text, Paint paint, Canvas canvas, Size size) {
    double x = lowerX + labelDateXMapList.$3*canvasWidth;
    canvas.drawLine(Offset(x, y), Offset(x, y - dy), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y), width: radius, height: radius), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y-dy), width: radius, height: radius), paint);
    Utils.drawText(x, y - dy, dy < 0 ? -(radius*2) : radius*4,
        '${labelDateXMapList.$1}',
        canvas,size, maxWidth: 300, maxLines: 5);
  }

  StrategyMarker copy(){
    return StrategyMarker(strategyParameters, therapies, drugs, strategyIdDateXLabelMapList, labelDateXMapList,
        Utils.getCapitalizedWords(text), startingDate, endingDate, y, radius, dy, isStart, isEnd, selected);
  }
}