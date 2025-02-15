
import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../utils/utils.dart';
import '../../widgets/yaml_editor/strategies/strategy_detail_card_form.dart';

class CyclingStrategy extends Strategy {
  late List<int> therapyIds;
  late int cyclingTime;

  CyclingStrategy({
    required String id,
    required String name,
    required this.therapyIds,
    required this.cyclingTime,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, type: StrategyType.Cycling, controllers: controllers);

  factory CyclingStrategy.fromYaml(dynamic yaml) {
    if (yaml is! Map) {
      throw ArgumentError('Invalid YAML format for CyclingStrategy');
    }
    if (yaml['name'] == null || yaml['therapy_ids'] == null || yaml['cycling_time'] == null) {
      throw ArgumentError('Missing required fields in YAML for CyclingStrategy');
    }
    if (yaml['therapy_ids'] is! YamlList) {
      throw ArgumentError('Invalid therapy_ids format in YAML for CyclingStrategy');
    }
    if (yaml['cycling_time'] is! int) {
      throw ArgumentError('Invalid cycling_time format in YAML for CyclingStrategy');
    }

    String id = Uuid().v4();
    Map<String, TextEditingController> controllers = {};
    controllers[Utils.getFormKeyID(id, 'name')] = TextEditingController(text: yaml['name'].toString());
    controllers[Utils.getFormKeyID(id, 'therapy_ids')] = TextEditingController(text: yaml['therapy_ids'].toString());
    controllers[Utils.getFormKeyID(id, 'cycling_time')] = TextEditingController(text: yaml['cycling_time'].toString());

    return CyclingStrategy(
      id: id,
      name: yaml['name'],
      therapyIds: List<int>.from((yaml['therapy_ids'] as YamlList).toList()),
      cyclingTime: yaml['cycling_time'],
      controllers: controllers,
    );
  }

  @override
  String string() {
    return 'CyclingStrategy(name: $name, therapyIds: $therapyIds, cyclingTime: $cyclingTime)';
  }

  @override
  CyclingStrategyState createState() => CyclingStrategyState();

  @override
  Strategy copy() {
    String newId = Uuid().v4();
    Map<String, TextEditingController> newControllers = {};
    newControllers[Utils.getFormKeyID(newId, 'name')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'name')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'therapy_ids')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'cycling_time')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'cycling_time')]!.text);

    return CyclingStrategy(
      id: newId,
      name: name,
      therapyIds: List<int>.from(therapyIds),
      cyclingTime: cyclingTime,
      controllers: newControllers,
    );
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    therapyIds = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    cyclingTime = int.parse(controllers[Utils.getFormKeyID(id, 'cycling_time')]!.text);
    // print('Updated CyclingStrategy: $name, therapyIds: $therapyIds, cyclingTime: $cyclingTime');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type.typeAsString,
      'therapy_ids': therapyIds,
      'cycling_time': cyclingTime
    };
  }
}

class CyclingStrategyState extends StrategyState<CyclingStrategy> {
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
                therapyMap: ref.read(therapyMapProvider.notifier).get(),
            ),
            StrategyDetailCardForm(
                type: StrategyDetailCardFormType.integer,
                controllerKey: 'cycling_time',
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
