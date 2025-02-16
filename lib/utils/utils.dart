import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/strategy_parameters.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

import '../models/events/event.dart';
import '../models/markers/strategy_marker.dart';
import '../models/strategies/AdaptiveCyclingStrategy.dart';
import '../models/strategies/CyclingStrategy.dart';
import '../models/strategies/MFTRebalancingStrategy.dart';
import '../models/strategies/MFTStrategy.dart';
import '../models/strategies/NestedMFTMultiLocationStrategy.dart';
import '../models/strategies/NestedMFTStrategy.dart';
import '../models/strategies/SFTStrategy.dart';
import '../models/strategies/strategy.dart';
import '../models/therapy.dart';
import '../providers/data_providers.dart';

class Utils {

  static void drawMarker(double x, double y, double dy, double radius, String text, Paint paint, Canvas canvas, Size size, {maxLines = 1, color = Colors.black}) {
    // canvas.drawLine(Offset(x, y - radius), Offset(x, y - dy + radius), paint);
    // canvas.drawCircle(Offset(x, y), radius, paint);
    // canvas.drawCircle(Offset(x, y - dy), radius, paint);
    canvas.drawLine(Offset(x, y), Offset(x, y - dy), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y), width: radius, height: radius), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x,y-dy), width: radius, height: radius), paint);
    drawText(x, y - dy, dy < 0 ? -(radius*2) : radius*5, text, canvas, size, color: color, maxLines: maxLines);
  }

  static void drawText(double x, double y, double dy, String text, Canvas canvas, Size size,{int maxLines = 1, color = Colors.black, maxWidth = 150}) {
    var textStyle = TextStyle(
      color: color,
      fontSize: 16,
      overflow: TextOverflow.ellipsis,
      // background: Paint()
      //   ..color = color
      //   ..strokeWidth = 2
      //   ..strokeJoin = StrokeJoin.round
      //   ..strokeCap = StrokeCap.round
      //   ..style = PaintingStyle.fill,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      ellipsis: '...',
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: maxWidth,
    );
    // textPainter.paint(canvas,
    //     Offset((size.width - textPainter.width) / 2,(size.height - textPainter.height) / 2));
    textPainter.paint(canvas, Offset(x-textPainter.width/2, y - dy));
  }

  /// Returns a random date between [start] and [end] formatted as specified by [format].
  static String getRandomDateInRange(DateTime start, DateTime end, String format) {
    // Convert the start and end dates to milliseconds since epoch.
    int startMillis = start.millisecondsSinceEpoch;
    int endMillis = end.millisecondsSinceEpoch;

    // Compute the difference.
    int diff = endMillis - startMillis;

    // Generate a random offset using nextDouble.
    int randomOffset = (Random().nextDouble() * diff).floor();

    // Create the random DateTime.
    DateTime randomDate = DateTime.fromMillisecondsSinceEpoch(startMillis + randomOffset);

    // Format the date using the provided format string.
    return DateFormat(format).format(randomDate);
  }

  static String getFormKeyID(String id, String label){
    return '$id#${label.replaceAll(' ', '_')}';
  }

  static getControllerKeyLabel(String key){
    //find label position in key, extract from 'date' to end
    List<String> keyParts = key.split('#');
    if(keyParts.last.contains('date')){
      return getCapitalizedWords(keyParts.last.replaceAll('_', '#'));
    }
    return getCapitalizedWords(keyParts.last.replaceAll('_', ' '));
  }

  static (String, Map<String, TextEditingController>) getNewFormControllers(
      String oldId, Map<String, TextEditingController> oldControllers) {
    final newId = const Uuid().v4();
    final newControllers = <String, TextEditingController>{};

    for (var entry in oldControllers.entries) {
      final newKey = entry.key.replaceAll(oldId, newId);
      newControllers[newKey] = TextEditingController(text: entry.value.text);
    }
    return (newId, newControllers);
  }

  static DateTime getEarliestDate(List<DateTime> dates){
    if(dates.length == 1){
      return dates.first;
    }
    return dates.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  static String getEarliestDateString(List<DateTime> dates){
    if(dates.length == 1){
      return DateFormat('yyyy/MM/dd').format(dates.first);
    }
    return DateFormat('yyyy/MM/dd').format(dates.reduce((a, b) => a.isBefore(b) ? a : b));
  }

  static String getControllerFirstDateKey(Map<String, TextEditingController> controllers){
    List<DateTime> dates = [];
    for (var key in controllers.keys) {
      if (key.contains('date')) {
        dates.add(DateFormat('yyyy/MM/dd').parse(controllers[key]!.text));
      }
    }
    return DateFormat('yyyy/MM/dd').format(dates.reduce((a, b) => a.isBefore(b) ? a : b));
  }

  static Color generateColorFromString(String str) {
    int hash = str.hashCode;
    return Color.fromARGB(
      255,
      (hash & 0xFF0000) >> 16,
      (hash & 0x00FF00) >> 8,
      hash & 0x0000FF,
    );
  }

  static Color invertColor(Color color) {
    return Color.from(
      alpha: color.a,
      red: 255 - color.r,
      green: 255 - color.g,
      blue: 255 - color.b,
    );
  }

  static String removeExtraChars(String value){
    if(value.contains('[') && value.contains(']')){
      value = value.replaceAll('[', '');
      value = value.replaceAll(']', '');
    }
    if(value.contains(' ')){
      value = value.replaceAll(' ', '');
    }
    return value;
  }

  static List<List<double>> extractDoubleMatrix(String input) {
    return input
        .replaceAll('[[', '')
        .replaceAll(']]', '')
        .split('], [') // Splitting by '], [' to separate locations
        .map((row) => row
        .split(',')
        .map((value) => double.tryParse(value.trim()) ?? 0.0)
        .toList())
        .toList();
  }

  static List<double> extractDoubleList(String input) {
    return input
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((value) => double.tryParse(value.trim()) ?? 0.0)
        .toList();
  }

  static List<List<int>> extractIntegerMatrix(String input) {
    return input
        .replaceAll('[[', '')
        .replaceAll(']]', '')
        .split('], [') // Splitting by '], [' to separate locations
        .map((row) => row
        .split(',')
        .map((value) => int.tryParse(value.trim()) ?? 0)
        .toList())
        .toList();
  }

  static List<int> extractIntegerList(String input) {
    return input
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((value) => int.tryParse(value.trim()) ?? 0)
        .toList();
  }

  static String getCapitalizedString(String input){
    return input[0].toUpperCase() + input.substring(1);
  }

  static String getCapitalizedWords(String input){
    return input.split(' ').map((word) => getCapitalizedString(word)).join(' ')
        .replaceAll('_', ' ').replaceAll('#', ' ');
  }

  static List<int> getTherapyIndex(StrategyParameters strategyParameters,Strategy strategy){
    if(strategy.type == StrategyType.SFT){
      SFTStrategy sftStrategy = strategy as SFTStrategy;
      return sftStrategy.therapyIds;
    }
    else if(strategy.type == StrategyType.Cycling){
      CyclingStrategy cyclingStrategy = strategy as CyclingStrategy;
      return cyclingStrategy.therapyIds;
    }
    else if(strategy.type == StrategyType.AdaptiveCycling){
      AdaptiveCyclingStrategy adaptiveCyclingStrategy = strategy as AdaptiveCyclingStrategy;
      return adaptiveCyclingStrategy.therapyIds;
    }
    else if(strategy.type == StrategyType.MFT){
      MFTStrategy mftStrategy = strategy as MFTStrategy;
      return mftStrategy.therapyIds;
    }
    else if(strategy.type == StrategyType.MFTRebalancing){
      MFTRebalancingStrategy mftRebalancingStrategy = strategy as MFTRebalancingStrategy;
      return mftRebalancingStrategy.therapyIds;
    }
    else if(strategy.type == StrategyType.NestedMFT){
      NestedMFTStrategy nestedMFTStrategy = strategy as NestedMFTStrategy;
      List<int> therapyIds = [];
      for(int strategyId in nestedMFTStrategy.strategyIds){
        Strategy? strategy = strategyParameters.strategyDb[strategyId];
        therapyIds.addAll(getTherapyIndex(strategyParameters,strategy!));
      }
      return therapyIds;
    }
    else if(strategy.type == StrategyType.NestedMFTMultiLocation){
      NestedMFTMultiLocationStrategy nestedMFTMultiLocationStrategy = strategy as NestedMFTMultiLocationStrategy;
      List<int> therapyIds = [];
      for(int strategyId in nestedMFTMultiLocationStrategy.strategyIds){
        Strategy? strategy = strategyParameters.strategyDb[strategyId];
        therapyIds.addAll(getTherapyIndex(strategyParameters,strategy!));
      }
      return therapyIds;
    }
    return [];
  }

  static List<Therapy> getTherapies(Map<int,Therapy> therapyMap,StrategyParameters strategyParameters,Strategy strategy) {
    List<int> therapyIndex = getTherapyIndex(strategyParameters,strategy);
    return therapyIndex.map((e) => therapyMap[e]!).toList();
  }

  static StrategyMarker getEventStrategyMarkers(WidgetRef ref,Event newEvent){
    DateTime startingDates = ref.read(dateMapProvider.notifier).get()['starting_date']!;
    DateTime endingDates = ref.read(dateMapProvider.notifier).get()['ending_date']!;
    StrategyMarker newStrategyMarker = ref.read(strategyMarkerListProvider.notifier).get().first.copy();
    newStrategyMarker.startingDate = startingDates;
    newStrategyMarker.endingDate = endingDates;
    newStrategyMarker.strategyIdDateXLabelMapList.clear();
    newStrategyMarker.labelDateXMapList.clear();
    if(newEvent.name.contains('strategy')){
      List<DateTime> strategyDates = newEvent.dates();
      List<int> strategyIds = newEvent.valuesByKey('strategy_id').map((e) => int.parse(e)).toList();

      // print('add new event $strategyIds');

      List<(String,DateTime)> cyclingDates = [];
      List<List<int>> cyclingTherapyIndex = [];
      List<List<Therapy>> cyclingTherapies = [];
      List<int> cyclingDays = [];
      for(int i = 0; i < strategyIds.length; i++){
        Strategy? cyclingStrategy = ref.read(strategyParametersProvider.notifier).get().strategyDb[strategyIds[i]];
        if(cyclingStrategy!.type == StrategyType.Cycling){
          String cKey = getFormKeyID(cyclingStrategy.id, 'cycling_time');
          int cyclingDay = int.parse(cyclingStrategy.controllers[cKey]!.text);
          cyclingDays.add(cyclingDay);
          cyclingTherapyIndex.add(getTherapyIndex(
              ref.read(strategyParametersProvider.notifier).get(),cyclingStrategy));
          cyclingDates.add(('start',strategyDates[i]));
        }
        // if(cyclingStrategy.type == StrategyType.AdaptiveCycling){
        //   String cKeyDelay = getFormKeyID(cyclingStrategy.id, 'delay_until_actual_trigger');
        //   String cKeyOff = getFormKeyID(cyclingStrategy.id, 'turn_off_days');
        //   String cKey = getFormKeyID(cyclingStrategy.id, 'cycling_time');
        //   int cyclingDay = int.parse(cyclingStrategy.controllers[cKey]!.text);
        //   cyclingDays.add(cyclingDay);
        //   cyclingTherapyIndex.add(getTherapyIndex(
        //       ref.read(strategyParametersProvider.notifier).get(),cyclingStrategy));
        //   cyclingDates.add(('start',strategyDates[i]));
        // }
        // if(cyclingStrategy.type == StrategyType.MFTRebalancing){
        //   cyclingDates.clear();
        //   String cKeyDelay = getFormKeyID(cyclingStrategy.id, 'delay_until_actual_trigger');
        //   String cKeyOff = getFormKeyID(cyclingStrategy.id, 'update_duration_after_rebalancing');
        //   int cyclingDelayDay = int.parse(cyclingStrategy.controllers[cKeyDelay]!.text);
        //   int cyclingUpdateDay= int.parse(cyclingStrategy.controllers[cKeyOff]!.text);
        //   DateTime endingDates = ref.read(dateMapProvider.notifier).get()['ending_date']!;
        //   DateTime startDate = strategyDates[i];
        //   while(startDate.isBefore(endingDates)){
        //     cyclingDates.add(('delay',startDate));
        //     startDate = startDate.add(Duration(days: cyclingDelayDay));
        //     if(startDate.isAfter(endingDates)){
        //       break;
        //     }
        //   }
        //   while(startDate.isBefore(endingDates)){
        //     cyclingDates.add(('update',startDate));
        //     startDate = startDate.add(Duration(days: cyclingUpdateDay));
        //     if(startDate.isAfter(endingDates)){
        //       break;
        //     }
        //   }
        //   // print('MFTRebalancing $cyclingDates');
        // }
        // if(cyclingStrategy.type == StrategyType.NestedMFT || cyclingStrategy.type == StrategyType.NestedMFTMultiLocation){
        //   cyclingDates.clear();
        //   String cKeyDelay = getFormKeyID(cyclingStrategy.id, 'peak_after');
        //   int cyclingPeakDay = int.parse(cyclingStrategy.controllers[cKeyDelay]!.text);
        //   DateTime endingDates = ref.read(dateMapProvider.notifier).get()['ending_date']!;
        //   DateTime startDate = strategyDates[i];
        //   while(startDate.isBefore(endingDates)){
        //     startDate = startDate.add(Duration(days: cyclingPeakDay));
        //     cyclingDates.add(('peak',startDate));
        //     if(startDate.isAfter(endingDates)){
        //       break;
        //     }
        //   }
        //   // print('NestedMFT $cyclingDates');
        // }
      }
      for(var cyclingTherapyIndex in cyclingTherapyIndex){
        cyclingTherapies.add(cyclingTherapyIndex.map((e) => ref.read(therapyMapProvider.notifier).get()[e]!).toList());
      }
      List<List<(String,DateTime)>> finalCycleDates = [];
      for(var i = 0; i < cyclingDates.length; i++){
        List<(String,DateTime)> finalCycleDate = [];
        DateTime startDate = cyclingDates[i].$2;
        if(i == cyclingDates.length-1){
          int counter = 0;
          while(startDate.isBefore(endingDates)){
            finalCycleDate.add((cyclingTherapies[i][counter].name,startDate));
            startDate = startDate.add(Duration(days: cyclingDays[i]));
            if(startDate.isAfter(endingDates)){
              break;
            }
            counter++;
            if(counter == cyclingTherapies[i].length){
              counter = 0;
            }
          }
        }
        else{
          int counter = 0;
          while(startDate.isBefore(cyclingDates[i+1].$2)){
            finalCycleDate.add((cyclingTherapies[i][counter].name,startDate));
            startDate = startDate.add(Duration(days: cyclingDays[i]));
            if(startDate.isAfter(cyclingDates[i+1].$2) || startDate.isAfter(endingDates)){
              break;
            }
            counter++;
            if(counter == cyclingTherapies[i].length){
              counter = 0;
            }
          }
        }
        finalCycleDates.add(finalCycleDate);
      }
      // add ending date
      finalCycleDates.last.add(('end',endingDates));
      // print('FinalCycleDates $finalCycleDates');

      for(var i = 0; i < strategyDates.length; i++){
        newStrategyMarker.strategyIdDateXLabelMapList.add((strategyIds[i],strategyDates[i],0.0,'$i'));
      }
      for(int i = 0; i < finalCycleDates.length; i++){
        for(int j = 0; j < finalCycleDates[i].length; j++){
          newStrategyMarker.labelDateXMapList.add(('${i}#${finalCycleDates[i][j].$1}',finalCycleDates[i][j].$2,0.0));
        }
      }
      newStrategyMarker.updateX();
    }
    return newStrategyMarker;
  }
}
