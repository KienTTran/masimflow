import 'package:flutter/material.dart';
import 'package:masimflow/models/markers/marker.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/models/strategy_parameters.dart';
import 'package:masimflow/models/therapy.dart';
import '../../utils/utils.dart';
import '../drug.dart';
import '../strategies/AdaptiveCyclingStrategy.dart';
import '../strategies/CyclingStrategy.dart';
import '../strategies/MFTRebalancingStrategy.dart';
import '../strategies/MFTStrategy.dart';
import '../strategies/NestedMFTMultiLocationStrategy.dart';
import '../strategies/NestedMFTStrategy.dart';
import '../strategies/SFTStrategy.dart';

class StrategyMarker extends Marker {
  final bool isStart;
  final bool isEnd;
  final StrategyParameters strategyParameters;
  final Map<int, Therapy> therapies;
  final Map<int, Drug> drugs;
  final String text;
  late List<(DateTime,int, double)> strategyIdDateXMapList;

  @override
  bool shouldRepaint(StrategyMarker oldDelegate) => true;

  StrategyMarker(this.strategyParameters, this.therapies, this.drugs, this.strategyIdDateXMapList, this.text,
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
    // date = strategyIdDateXMapList.first.$1;
    // print('StrategyMarker id: $id');
    setStartingDate(startingDate);
    setEndingDate(endingDate);
    // setDate(date);
    updateX();
  }

  void updateX(){
    strategyIdDateXMapList = strategyIdDateXMapList.map((strategyIdDateXMap) {
      DateTime date = strategyIdDateXMap.$1;
      int strategyId = strategyIdDateXMap.$2;
      double x = (date.difference(startingDate).inDays / endingDate.difference(startingDate).inDays);
      return (date, strategyId, x);
    }).toList();
  }

  @override
  void paint(Canvas canvas, Size size) {
    updatePainter();
    if(y == -1) {
      y = defaultY;
    }
    canvasWidth = upperX - lowerX;
    for(var strategyIdDateXMap in strategyIdDateXMapList){
      drawStrategyMarker(strategyIdDateXMap, y, dy, radius, text, painter, canvas, size);
    }
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

  void drawStrategyMarker((DateTime,int,double) strategyIdDateXMap, double y, double dy, double radius, String text, Paint paint, Canvas canvas, Size size) {
    double x = lowerX + strategyIdDateXMap.$3*canvasWidth;
    canvas.drawLine(Offset(x, y), Offset(x, y - dy), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y), width: radius, height: radius), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y-dy), width: radius, height: radius), paint);
    List<String> therapyNames = [];
    List<int> therapyIds = [];
    String strategyName = '';
    int strategyId = strategyIdDateXMap.$2;
    if(strategyId == -1){
      therapyIds = getTherapies(strategyParameters.strategyDb[strategyParameters.initialStrategyId]!);
      strategyName = text;
    }
    else{
      therapyIds = getTherapies(strategyParameters.strategyDb[strategyId]!);
      strategyName = strategyParameters.strategyDb[strategyId]!.name;
    }
    for(int therapyId in therapyIds){
      therapyNames.add('${therapies[therapyId]!.name}');
    }
    Utils.drawText(x, y - dy, dy < 0 ? -(radius*2) : radius*4,
        '$strategyName\n${therapyNames.toString()}',
        canvas,size, maxWidth: 300, maxLines: 5);
  }

  StrategyMarker copy(){
    return StrategyMarker(strategyParameters, therapies, drugs, strategyIdDateXMapList, Utils.getCapitalizedWords(text), startingDate, endingDate, y, radius, dy, isStart, isEnd, selected);
  }
}