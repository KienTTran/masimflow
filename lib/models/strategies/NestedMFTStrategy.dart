import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../utils/utils.dart';
import '../../widgets/yaml_editor/strategies/strategy_detail_card_form.dart';

class NestedMFTStrategy extends Strategy {
  late List<int> strategyIds;
  late List<double> startDistribution;
  late List<double> peakDistribution;
  late int peakAfter;

  NestedMFTStrategy({
    required String id,
    required String name,
    required this.strategyIds,
    required this.startDistribution,
    required this.peakDistribution,
    required this.peakAfter,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, type: StrategyType.NestedMFT, controllers: controllers);

  factory NestedMFTStrategy.fromYaml(dynamic yaml) {
    if (yaml is! Map) {
      throw ArgumentError('Invalid YAML format for NestedMFTStrategy');
    }
    if (yaml['name'] == null ||
        yaml['strategy_ids'] == null ||
        yaml['start_distribution'] == null ||
        yaml['peak_distribution'] == null ||
        yaml['peak_after'] == null) {
      throw ArgumentError('Missing required fields in YAML for NestedMFTStrategy');
    }
    if (yaml['strategy_ids'] is! YamlList) {
      throw ArgumentError('Invalid strategy_ids format in YAML for NestedMFTStrategy');
    }
    if (yaml['start_distribution'] is! YamlList ||
        yaml['peak_distribution'] is! YamlList) {
      throw ArgumentError('Invalid distribution format in YAML for NestedMFTStrategy');
    }
    if (yaml['start_distribution'].length != yaml['strategy_ids'].length ||
        yaml['peak_distribution'].length != yaml['strategy_ids'].length) {
      throw ArgumentError('Distribution lengths must match strategy_ids length in YAML for NestedMFTStrategy');
    }
    if (yaml['peak_after'] is! int) {
      throw ArgumentError('Invalid peak_after format in YAML for NestedMFTStrategy');
    }

    String id = Uuid().v4();
    Map<String, TextEditingController> controllers = {};
    controllers[Utils.getFormKeyID(id, 'name')] = TextEditingController(text: yaml['name'].toString());
    controllers[Utils.getFormKeyID(id, 'strategy_ids')] = TextEditingController(text: yaml['strategy_ids'].toString());
    controllers[Utils.getFormKeyID(id, 'start_distribution')] = TextEditingController(text: yaml['start_distribution'].toString());
    controllers[Utils.getFormKeyID(id, 'peak_distribution')] = TextEditingController(text: yaml['peak_distribution'].toString());
    controllers[Utils.getFormKeyID(id, 'peak_after')] = TextEditingController(text: yaml['peak_after'].toString());

    return NestedMFTStrategy(
      id: id,
      name: yaml['name'],
      strategyIds: List<int>.from((yaml['strategy_ids'] as YamlList).toList()),
      startDistribution: List<double>.from(
          (yaml['start_distribution'] as YamlList).map((v) => (v as num).toDouble())),
      peakDistribution: List<double>.from(
          (yaml['peak_distribution'] as YamlList).map((v) => (v as num).toDouble())),
      peakAfter: yaml['peak_after'],
      controllers: controllers,
    );
  }

  @override
  String string() {
    return 'NestedMFTStrategy(name: $name, strategyIds: $strategyIds, startDistribution: $startDistribution, peakDistribution: $peakDistribution, peakAfter: $peakAfter)';
  }

  @override
  NestedMFTStrategyState createState() => NestedMFTStrategyState();

  @override
  Strategy copy() {
    String newId = Uuid().v4();
    Map<String, TextEditingController> newControllers = {};
    newControllers[Utils.getFormKeyID(newId, 'name')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'name')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'strategy_ids')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'strategy_ids')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'start_distribution')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'start_distribution')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'peak_distribution')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'peak_distribution')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'peak_after')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'peak_after')]!.text);

    return NestedMFTStrategy(
      id: newId,
      name: controllers[Utils.getFormKeyID(id, 'name')]!.text,
      strategyIds: Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'strategy_ids')]!.text),
      startDistribution: Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'start_distribution')]!.text),
      peakDistribution: Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'peak_distribution')]!.text),
      peakAfter: int.parse(controllers[Utils.getFormKeyID(id, 'peak_after')]!.text),
      controllers: newControllers,
    );
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    strategyIds = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'strategy_ids')]!.text);
    startDistribution = Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'start_distribution')]!.text);
    peakDistribution = Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'peak_distribution')]!.text);
    peakAfter = int.parse(controllers[Utils.getFormKeyID(id, 'peak_after')]!.text);
    // print('Updated NestedMFTStrategy: $name, strategyIds: $strategyIds, startDistribution: $startDistribution, peakDistribution: $peakDistribution, peakAfter: $peakAfter');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type.typeAsString,
      'strategy_ids': strategyIds,
      'start_distribution': startDistribution,
      'peak_distribution': peakDistribution,
      'peak_after': peakAfter,
    };
  }
}

class NestedMFTStrategyState extends StrategyState<NestedMFTStrategy> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.formWidth * 0.85,
      child: ShadForm(
        key: widget.formKey,
        enabled: widget.formEditable,
        autovalidateMode: ShadAutovalidateMode.always,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            StrategyDetailCardForm(
                type: StrategyDetailCardFormType.string,
                controllerKey: 'name',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                strategy: widget
            ),
            StrategyDetailCardForm(
                type: StrategyDetailCardFormType.multipleStrategy,
                controllerKey: 'strategy_ids',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                strategy: widget,
                strategyParameters: ref.read(strategyParametersProvider.notifier).get()
            ),
            StrategyDetailCardForm(
                type: StrategyDetailCardFormType.doubleArray,
                controllerKey: 'start_distribution',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                strategy: widget,
                typeKey: 'strategy_ids',
                lower: 0.0,
                upper: 1.0
            ),
            StrategyDetailCardForm(
                type: StrategyDetailCardFormType.doubleArray,
                controllerKey: 'peak_distribution',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                strategy: widget,
                typeKey: 'strategy_ids',
                lower: 0.0,
                upper: 1.0
            ),
            StrategyDetailCardForm(
                type: StrategyDetailCardFormType.integer,
                controllerKey: 'peak_after',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                strategy: widget,
                lower: 0.0,
                upper: -1.0,
            ),
          ],
        ),
      ),
    );
  }
}
