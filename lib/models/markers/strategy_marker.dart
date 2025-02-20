import 'package:flutter/material.dart';
import 'package:masimflow/models/markers/marker.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/models/strategies/strategy_parameters.dart';
import 'package:masimflow/models/therapies/therapy.dart';
import '../../utils/utils.dart';
import '../drugs/drug.dart';

class StrategyMarker extends Marker {
  final bool isStart;
  final bool isEnd;
  final StrategyParameters strategyParameters;
  final Map<String,Therapy> therapies;
  final Map<String,Drug> drugs;
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
    // this.initialDy = dy;
    // this.index = 0;
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
    // print('startingDate: $startingDate');
    // print('endingDate: $endingDate');
    // print('before strategyIdDateXLabelMapList: $strategyIdDateXLabelMapList');
    // print('before labelDateXMapList: $labelDateXMapList');
    strategyIdDateXLabelMapList = strategyIdDateXLabelMapList.map((strategyIdDateXMap) {
      int strategyId = strategyIdDateXMap.$1;
      DateTime date = strategyIdDateXMap.$2;
      double x = (date.difference(startingDate).inDays.toDouble() / endingDate.difference(startingDate).inDays.toDouble());
      String label = strategyIdDateXMap.$4;
      return (strategyId, date, x, label);
    }).toList();
    labelDateXMapList = labelDateXMapList.map((labelDateXMap) {
      String label = labelDateXMap.$1;
      DateTime date = labelDateXMap.$2;
      double x = (date.difference(startingDate).inDays.toDouble() / endingDate.difference(startingDate).inDays.toDouble());
      return (label, date, x);
    }).toList();
    // print('after strategyIdDateXLabelMapList: ${strategyIdDateXLabelMapList}');
    // print('after labelDateXMapList: ${labelDateXMapList}');
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
    for(int i = 0; i< labelDateXMapList.length; i++){
      if(labelDateXMapList[i].$1.isNotEmpty) {
        if(i == labelDateXMapList.length - 1){
          drawStrategyMarker3(
              labelDateXMapList[i],
              labelDateXMapList[i],
              y,
              dy,
              radius,
              text,
              painter,
              canvas,
              size);
        }
        else{
          drawStrategyMarker3(
              labelDateXMapList[i],
              labelDateXMapList[i+1],
              y,
              dy,
              radius,
              text,
              painter,
              canvas,
              size);
        }
      }
    }
  }

  void drawStrategyMarker1((int,DateTime,double,String) strategyIdDateXLabelMap, double y, double dy, double radius, String text, Paint paint, Canvas canvas, Size size) {
    double x = lowerX + strategyIdDateXLabelMap.$3*canvasWidth;
    // canvas.drawLine(Offset(x, y), Offset(x, y - dy), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y), width: radius, height: radius), paint);
    // canvas.drawRect(Rect.fromCenter(center: Offset(x,y-dy), width: radius, height: radius), paint);
    List<String> therapyNames = [];
    List<int> therapyIds = [];
    String strategyName = '';
    int strategyId = strategyIdDateXLabelMap.$1;
    if(strategyId == -1){
      therapyIds = Utils.getTherapyIndex(strategyParameters,strategyParameters.strategyDb[strategyParameters.initialStrategyId]!);
      strategyName = strategyParameters.strategyDb[strategyParameters.initialStrategyId]!.name;
    }
    else{
      therapyIds = Utils.getTherapyIndex(strategyParameters,strategyParameters.strategyDb[strategyId]!);
      strategyName = strategyParameters.strategyDb[strategyId]!.name;
    }
    for(int therapyId in therapyIds){
      therapyNames.add('${therapies.values.elementAt(therapyId).name}');
    }
    int strategyIndex = 1;
    if(strategyIdDateXLabelMap.$4.isNotEmpty){
      strategyIndex = int.parse(strategyIdDateXLabelMap.$4);
    }
    if(strategyId == -1){
      Utils.drawText(x, y - dy, dy < 0 ? -(radius*4) : (radius*4),
          '$strategyName\n${therapyNames.toString()}',
          canvas,size, maxWidth: 300, maxLines: 5);
    }
    else{
      Utils.drawText(x, y - dy, dy < 0 ? -(strategyIndex*radius*4) : (strategyIndex*radius*4),
          '$strategyName',
          // '$strategyName\n${strategyIdDateXLabelMap.$4}\n${therapyNames.toString()}',
          canvas,size, maxWidth: 300, maxLines: 5);
    }
  }

  void drawStrategyMarker2((String,DateTime,double) labelDateXMap, double y, double dy, double radius, String text, Paint paint, Canvas canvas, Size size) {
    double x = lowerX + labelDateXMap.$3*canvasWidth;
    int therapyIndex = int.parse(labelDateXMap.$1.split('#').first) + 1;
    String therapyLabel = labelDateXMap.$1.split('#').last;
    // canvas.drawLine(Offset(x, y), Offset(x, y - (dy)), paint);
    final painter = Paint()
      ..color = Utils.generateColorFromString(therapyIndex.toString())
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y), width: radius, height: radius), painter);
    // canvas.drawRect(Rect.fromCenter(center: Offset(x,y-dy), width: radius, height: radius), paint);
    Utils.drawText(x, y - (dy), dy < 0 ? -(therapyIndex*radius*4) : (therapyIndex*radius*4),
        '${therapyLabel}',canvas,size, maxWidth: 300, maxLines: 10);
  }

  void drawStrategyMarker3((String,DateTime,double) labelDateXMapFrom, (String,DateTime,double) labelDateXMapTo, double y, double dy, double radius, String text, Paint paint, Canvas canvas, Size size) {
    double xFrom = lowerX + labelDateXMapFrom.$3*canvasWidth;
    double xTo = lowerX + labelDateXMapTo.$3*canvasWidth;
    int therapyIndex = int.parse(labelDateXMapFrom.$1.split('#').first) + 1;
    String therapyLabelFrom = labelDateXMapFrom.$1.split('#').last;
    String therapyLabelTo = labelDateXMapTo.$1.split('#').last;
    final painter = Paint()
      ..color = Utils.generateColorFromString(therapyIndex.toString())
      ..style = PaintingStyle.fill
      ..strokeWidth = 6;
    canvas.drawRect(Rect.fromCenter(center: Offset(xFrom,y), width: radius, height: radius), painter);
    final textPainterFrom = TextPainter(
      text: TextSpan(text: therapyLabelFrom,
          style: TextStyle(
          color: color,
          fontSize: 16,
          overflow: TextOverflow.ellipsis)
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
      ellipsis: '...',
    );
    textPainterFrom.layout(
      minWidth: 0,
      maxWidth: 300,
    );
    textPainterFrom.paint(canvas, Offset(xFrom-textPainterFrom.width/2, y - (dy - therapyIndex*radius*4)));
    final textPainterTo = TextPainter(
      text:TextSpan(text: therapyLabelTo,
          style: TextStyle(
              color: color,
              fontSize: 16,
              overflow: TextOverflow.ellipsis)
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
      ellipsis: '...',
    );
    textPainterTo.layout(
      minWidth: 0,
      maxWidth: 300,
    );
    if(xFrom != xTo && xFrom + textPainterFrom.width/1.5 < xTo - textPainterTo.width/1.5){
      canvas.drawLine(Offset(xFrom + textPainterFrom.width/1.5, y + textPainterFrom.height/2 - (dy - therapyIndex*radius*4)),
          Offset(xTo - textPainterTo.width/1.5, y + textPainterFrom.height/2 - (dy - therapyIndex*radius*4)), painter);
    }
  }

  StrategyMarker copy(){
    return StrategyMarker(strategyParameters, therapies, drugs, strategyIdDateXLabelMapList, labelDateXMapList,
        Utils.getCapitalizedWords(text), startingDate, endingDate, y, radius, dy, isStart, isEnd, selected);
  }
}