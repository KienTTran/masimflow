import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../widgets/yaml_editor/strategies/strategy_detail_card_form.dart';
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

abstract class Strategy extends StrategyWidgetRender {
  final String id;
  late String name;
  final String type;
  late Map<String, TextEditingController> controllers;
  GlobalKey<ShadFormState> formKey = GlobalKey<ShadFormState>();
  late StrategyDetailCardForm strategyForm;
  late int initialIndex = 0;
  Map<String, dynamic> toYamlMap();
  Strategy copy();
  void update();

  Strategy({
    required this.id,
    required this.name,
    required this.type,
    required this.controllers
  });

  /// Factory constructor to choose the correct concrete subclass
  /// based on the YAML “type” field.
  factory Strategy.fromYaml(dynamic yaml) {
    final String strategyType = yaml['type'];
    switch (strategyType) {
      case 'MFT':
        return MFTStrategy.fromYaml(yaml);
      case 'SFT':
        return SFTStrategy.fromYaml(yaml);
      case 'Cycling':
        return CyclingStrategy.fromYaml(yaml);
      case 'AdaptiveCycling':
        return AdaptiveCyclingStrategy.fromYaml(yaml);
      case 'MFTRebalancing':
        return MFTRebalancingStrategy.fromYaml(yaml);
      case 'NestedMFT':
        return NestedMFTStrategy.fromYaml(yaml);
      case 'NestedMFTMultiLocation':
        return NestedMFTMultiLocationStrategy.fromYaml(yaml);
      default:
        throw Exception("Unknown strategy type: $strategyType");
    }
  }

  String string() => 'Strategy(name: $name, type: $type)';
}
