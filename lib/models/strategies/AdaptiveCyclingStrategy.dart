import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../utils/utils.dart';
import '../../widgets/yaml_editor/strategies/strategy_detail_card_form.dart';

class AdaptiveCyclingStrategy extends Strategy {
  late List<int> therapyIds;
  late double triggerValue;
  late int delayUntilActualTrigger;
  late int turnOffDays;

  AdaptiveCyclingStrategy({
    required String id,
    required String name,
    required this.therapyIds,
    required this.triggerValue,
    required this.delayUntilActualTrigger,
    required this.turnOffDays,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, type: StrategyType.AdaptiveCycling, controllers: controllers);

  factory AdaptiveCyclingStrategy.fromYaml(dynamic yaml) {
    if (yaml is! Map) {
      throw ArgumentError('Invalid YAML format for AdaptiveCyclingStrategy');
    }
    if (yaml['name'] == null ||
        yaml['therapy_ids'] == null ||
        yaml['trigger_value'] == null ||
        yaml['delay_until_actual_trigger'] == null ||
        yaml['turn_off_days'] == null) {
      throw ArgumentError('Missing required fields in YAML for AdaptiveCyclingStrategy');
    }
    if (yaml['therapy_ids'] is! YamlList) {
      throw ArgumentError('Invalid therapy_ids format in YAML for AdaptiveCyclingStrategy');
    }
    if (yaml['trigger_value'] is! num) {
      throw ArgumentError('Invalid trigger_value format in YAML for AdaptiveCyclingStrategy');
    }
    if (yaml['delay_until_actual_trigger'] is! int) {
      throw ArgumentError('Invalid delay_until_actual_trigger format in YAML for AdaptiveCyclingStrategy');
    }
    if (yaml['turn_off_days'] is! int) {
      throw ArgumentError('Invalid turn_off_days format in YAML for AdaptiveCyclingStrategy');
    }

    String id = Uuid().v4();
    Map<String, TextEditingController> controllers = {};
    controllers[Utils.getFormKeyID(id, 'name')] = TextEditingController(text: yaml['name'].toString());
    controllers[Utils.getFormKeyID(id, 'therapy_ids')] = TextEditingController(text: yaml['therapy_ids'].toString());
    controllers[Utils.getFormKeyID(id, 'trigger_value')] = TextEditingController(text: yaml['trigger_value'].toString());
    controllers[Utils.getFormKeyID(id, 'delay_until_actual_trigger')] = TextEditingController(text: yaml['delay_until_actual_trigger'].toString());
    controllers[Utils.getFormKeyID(id, 'turn_off_days')] = TextEditingController(text: yaml['turn_off_days'].toString());

    return AdaptiveCyclingStrategy(
      id: id,
      name: yaml['name'],
      therapyIds: List<int>.from((yaml['therapy_ids'] as YamlList).toList()),
      triggerValue: yaml['trigger_value'].toDouble(),
      delayUntilActualTrigger: yaml['delay_until_actual_trigger'],
      turnOffDays: yaml['turn_off_days'],
      controllers: controllers,
    );
  }

  @override
  String string() {
    return 'AdaptiveCyclingStrategy(name: $name, therapyIds: $therapyIds, triggerValue: $triggerValue, delayUntilActualTrigger: $delayUntilActualTrigger, turnOffDays: $turnOffDays)';
  }

  @override
  AdaptiveCyclingStrategyState createState() => AdaptiveCyclingStrategyState();

  @override
  Strategy copy() {
    String newId = Uuid().v4();
    Map<String, TextEditingController> newControllers = {};
    newControllers[Utils.getFormKeyID(newId, 'name')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'name')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'therapy_ids')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'trigger_value')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'trigger_value')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'delay_until_actual_trigger')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'delay_until_actual_trigger')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'turn_off_days')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'turn_off_days')]!.text);

    return AdaptiveCyclingStrategy(
      id: newId,
      name: controllers[Utils.getFormKeyID(id, 'name')]!.text,
      therapyIds: Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text),
      triggerValue: double.parse(controllers[Utils.getFormKeyID(id, 'trigger_value')]!.text),
      delayUntilActualTrigger: int.parse(controllers[Utils.getFormKeyID(id, 'delay_until_actual_trigger')]!.text),
      turnOffDays: int.parse(controllers[Utils.getFormKeyID(id, 'turn_off_days')]!.text),
      controllers: newControllers,
    );
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    therapyIds = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    triggerValue = double.parse(controllers[Utils.getFormKeyID(id, 'trigger_value')]!.text);
    delayUntilActualTrigger = int.parse(controllers[Utils.getFormKeyID(id, 'delay_until_actual_trigger')]!.text);
    turnOffDays = int.parse(controllers[Utils.getFormKeyID(id, 'turn_off_days')]!.text);
    // print('Updated AdaptiveCyclingStrategy: $name, therapyIds: $therapyIds, triggerValue: $triggerValue, delayUntilActualTrigger: $delayUntilActualTrigger, turnOffDays: $turnOffDays');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type.typeAsString,
      'therapy_ids': therapyIds,
      'trigger_value': triggerValue,
      'delay_until_actual_trigger': delayUntilActualTrigger,
      'turn_off_days': turnOffDays,
    };
  }
}

class AdaptiveCyclingStrategyState extends StrategyState<AdaptiveCyclingStrategy> {
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
              type: StrategyDetailCardFormType.multipleTherapy,
              controllerKey: 'therapy_ids',
              editable: widget.formEditable,
              width: widget.formWidth * 0.85,
              strategy: widget,
              therapyMap: ref.read(therapyMapProvider.notifier).get()
            ),
            StrategyDetailCardForm(
              type: StrategyDetailCardFormType.double,
              controllerKey: 'trigger_value',
              editable: widget.formEditable,
              width: widget.formWidth * 0.85,
              strategy: widget,
              lower: 0.0,
              upper: 1.0
            ),
            StrategyDetailCardForm(
              type: StrategyDetailCardFormType.integer,
              controllerKey: 'delay_until_actual_trigger',
              editable: widget.formEditable,
              width: widget.formWidth * 0.85,
              strategy: widget,
              lower: 0.0,
              upper: -1.0,
            ),
            StrategyDetailCardForm(
              type: StrategyDetailCardFormType.integer,
              controllerKey: 'turn_off_days',
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
