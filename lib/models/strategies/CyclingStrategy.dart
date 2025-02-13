
import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../utils/utils.dart';

class CyclingStrategy extends Strategy {
  late List<int> therapyIds;
  late int cyclingTime;

  CyclingStrategy({
    required String id,
    required String name,
    required this.therapyIds,
    required this.cyclingTime,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, type: 'Cycling', controllers: controllers);

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
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    therapyIds = controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text
        .replaceAll('[', '').replaceAll(']', '')
        .split(',')
        .map((e) => int.parse(e.trim()))
        .toList();
    cyclingTime = int.parse(controllers[Utils.getFormKeyID(id, 'cycling_time')]!.text);
    print('Updated CyclingStrategy: $name, therapyIds: $therapyIds, cyclingTime: $cyclingTime');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type,
      'therapy_ids': therapyIds,
      'cycling_time': cyclingTime
    };
  }
}

class CyclingStrategyState extends StrategyState<CyclingStrategy> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.strategyForm.width * 0.85,
      child: ShadForm(
        key: widget.formKey,
        autovalidateMode: ShadAutovalidateMode.always,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            widget.strategyForm.StrategyStringFormField('name'),
            widget.strategyForm.StrategyMultipleTherapyFormField(ref, ref.read(therapyMapProvider.notifier).get(), 'therapy_ids'),
            widget.strategyForm.StrategyIntegerFormField('cycling_time', lower: 0),
          ],
        ),
      ),
    );
  }
}
