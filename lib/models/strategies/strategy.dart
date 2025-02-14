import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'AdaptiveCyclingStrategy.dart';
import 'CyclingStrategy.dart';
import 'MFTRebalancingStrategy.dart';
import 'MFTStrategy.dart';
import 'NestedMFTMultiLocationStrategy.dart';
import 'NestedMFTStrategy.dart';
import 'SFTStrategy.dart';

class StrategyWidgetRender extends ConsumerStatefulWidget {
  // Constructor
  StrategyWidgetRender({Key? key}) : super(key: key);

  @override
  StrategyWidgetRenderState createState() => StrategyWidgetRenderState();
  
}

class StrategyWidgetRenderState<T extends StrategyWidgetRender> extends ConsumerState<T> {
  // Override build
  @override
  Widget build(BuildContext context) {
    return Text('StrategyWidgetRender');
  }
}

abstract class StrategyState<T extends Strategy> extends StrategyWidgetRenderState<T> {
  @override
  Widget build(BuildContext context); // Force subclasses to implement build
}

enum StrategyType {
  MFT,
  SFT,
  Cycling,
  AdaptiveCycling,
  MFTRebalancing,
  NestedMFT,
  NestedMFTMultiLocation;

  String get typeAsString {
    switch (this) {
      case StrategyType.MFT:
        return 'MFT';
      case StrategyType.SFT:
        return 'SFT';
      case StrategyType.Cycling:
        return 'Cycling';
      case StrategyType.AdaptiveCycling:
        return 'AdaptiveCycling';
      case StrategyType.MFTRebalancing:
        return 'MFTRebalancing';
      case StrategyType.NestedMFT:
        return 'NestedMFT';
      case StrategyType.NestedMFTMultiLocation:
        return 'NestedMFTMultiLocation';
    }
  }

  String get label {
    switch (this) {
      case StrategyType.MFT:
        return 'MFT';
      case StrategyType.SFT:
        return 'SFT';
      case StrategyType.Cycling:
        return 'Cycling';
      case StrategyType.AdaptiveCycling:
        return 'Adaptive Cycling';
      case StrategyType.MFTRebalancing:
        return 'MFT Rebalancing';
      case StrategyType.NestedMFT:
        return 'Nested MFT';
      case StrategyType.NestedMFTMultiLocation:
        return 'Nested MFT Multi Location';
    }
  }
}

abstract class Strategy extends StrategyWidgetRender {
  final String id;
  late String name;
  final StrategyType type;
  late Map<String, TextEditingController> controllers;
  GlobalKey<ShadFormState> formKey = GlobalKey<ShadFormState>();
  late double formWidth;
  bool formEditable = false;
  late int initialIndex = 0;
  Map<String, dynamic> toYamlMap();
  Strategy copy();
  void update();
  List<String> getYamlKeyList(){
    return ['strategy_parameters', 'strategy_db', initialIndex.toString()];
  }

  List<DateTime> dates() {
    List<DateTime> dates = [];
    for (var key in controllers.keys) {
      if (key.contains('date')) {
        dates.add(DateFormat('yyyy/MM/dd').parse(controllers[key]!.text));
      }
    }
    return dates;
  }

  Strategy({
    required this.id,
    required this.name,
    required this.type,
    required this.controllers
  });

  /// Factory constructor to choose the correct concrete subclass
  /// based on the YAML “type” field.
  factory Strategy.fromYaml(dynamic yaml) {
    final StrategyType strategyType = StrategyType.values.firstWhere((e) => e.typeAsString == yaml['type']);
    switch (strategyType) {
      case StrategyType.MFT:
        return MFTStrategy.fromYaml(yaml);
      case StrategyType.SFT:
        return SFTStrategy.fromYaml(yaml);
      case StrategyType.Cycling:
        return CyclingStrategy.fromYaml(yaml);
      case StrategyType.AdaptiveCycling:
        return AdaptiveCyclingStrategy.fromYaml(yaml);
      case StrategyType.MFTRebalancing:
        return MFTRebalancingStrategy.fromYaml(yaml);
      case StrategyType.NestedMFT:
        return NestedMFTStrategy.fromYaml(yaml);
      case StrategyType.NestedMFTMultiLocation:
        return NestedMFTMultiLocationStrategy.fromYaml(yaml);
    }
  }

  String string() => 'Strategy(name: $name, type: $type)';
}
