
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/marker.dart';
import 'package:masimflow/models/strategy.dart';
import 'package:masimflow/models/strategy_parameters.dart';
import 'package:masimflow/models/therapy.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

import 'drug.dart';

class StrategyMarker extends Marker {
  final double radius;
  final double dy;
  final String text;
  final bool isStart;
  final bool isEnd;
  late bool selected;
  final StrategyParameters strategyParameters;
  final Map<int, Therapy> therapies;
  final Map<int, Drug> drugs;

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

  @override
  bool shouldRepaint(StrategyMarker oldDelegate) => true;

  StrategyMarker(this.startingDate, this.endingDate, this.date, this.y, this.radius, this.dy, this.text, this.selected, this.isStart, this.isEnd,
      this.strategyParameters, this.therapies, this.drugs)
      : super(startingDate, endingDate, y, radius, dy, selected){
    canvasWidth = 0;
    lowerX = 0;
    upperX = 0;
    id = Uuid().v4();
    // print('StrategyMarker id: $id');
    setStartingDate(startingDate);
    setEndingDate(endingDate);
    setDate(date);
    if(!isStart && !isEnd){
      updateX();
    }
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
      }
      if (this.date.isAfter(endingDate)) {
        this.date = endingDate;
      }
    }
  }

  void setDate(DateTime date){
    checkDate(date);
    // print('setDate $isStart $isEnd ${DateFormat('yyyy/MM/dd').format(startingDate)} ${DateFormat('yyyy/MM/dd').format(endingDate)} ${DateFormat('yyyy/MM/dd').format(date)}');
    double totalDays = endingDate.difference(startingDate).inDays.toDouble();
    double daysSinceStart = date.difference(startingDate).inDays.toDouble();
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
    drawStrategyMarker(lowerX + x*canvasWidth, y, dy, radius, text,painter, canvas);
  }

  List<int> getTherapies(Strategy strategy){
    if(strategy.type == 'SFT'){
      SFTStrategy sftStrategy = strategy as SFTStrategy;
      return sftStrategy.therapyIds;
    }
    else if(strategy.type == 'Cycling'){
      CyclingStrategy cyclingStrategy = strategy as CyclingStrategy;
      return cyclingStrategy.therapyIds;
    }
    else if(strategy.type == 'AdaptiveCycling'){
      AdaptiveCyclingStrategy adaptiveCyclingStrategy = strategy as AdaptiveCyclingStrategy;
      return adaptiveCyclingStrategy.therapyIds;
    }
    else if(strategy.type == 'MFT'){
      MFTStrategy mftStrategy = strategy as MFTStrategy;
      return mftStrategy.therapyIds;
    }
    else if(strategy.type == 'MFTRebalancing'){
      MFTRebalancingStrategy mftRebalancingStrategy = strategy as MFTRebalancingStrategy;
      return mftRebalancingStrategy.therapyIds;
    }
    else if(strategy.type == 'NestedMFT'){
      NestedMFTStrategy nestedMFTStrategy = strategy as NestedMFTStrategy;
      List<int> therapyIds = [];
      for(int strategyId in nestedMFTStrategy.strategyIds){
        Strategy? strategy = strategyParameters.strategyDb[strategyId];
        therapyIds.addAll(getTherapies(strategy!));
      }
      return therapyIds;
    }
    else if(strategy.type == 'NestedMFTMultiLocation'){
      NestedMFTMultiLocationStrategy nestedMFTMultiLocationStrategy = strategy as NestedMFTMultiLocationStrategy;
      List<int> therapyIds = [];
      for(int strategyId in nestedMFTMultiLocationStrategy.strategyIds){
        Strategy? strategy = strategyParameters.strategyDb[strategyId];
        therapyIds.addAll(getTherapies(strategy!));
      }
      return therapyIds;
    }
    return [];
  }

  void drawStrategyMarker(double x, double y, double dy, double radius, String text, Paint paint, Canvas canvas) {
    canvas.drawLine(Offset(x, y), Offset(x, y - dy), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y), width: radius, height: radius), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y-dy), width: radius, height: radius), paint);
    List<int> therapyIds = getTherapies(strategyParameters.strategyDb[strategyParameters.initialStrategyId]!);
    drawText(x, y - dy, dy < 0 ? -(radius*2) : radius*4,
        '${therapyIds.toString()}',
        canvas);
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