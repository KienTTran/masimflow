
import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../utils/utils.dart';

class SFTStrategy extends Strategy {
  late List<int> therapyIds;

  SFTStrategy({
    required String id,
    required String name,
    required this.therapyIds,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, type: 'SFT', controllers: controllers);

  factory SFTStrategy.fromYaml(dynamic yaml) {
    if (yaml is! Map) {
      throw ArgumentError('Invalid YAML format for SFTStrategy');
    }
    if (yaml['name'] == null || yaml['therapy_ids'] == null) {
      throw ArgumentError('Missing required fields in YAML for SFTStrategy');
    }
    if (yaml['therapy_ids'] is! YamlList || yaml['therapy_ids'].length != 1) {
      throw ArgumentError('SFTStrategy must have exactly one therapy_id');
    }

    String id = Uuid().v4();
    Map<String, TextEditingController> controllers = {};
    controllers[Utils.getFormKeyID(id, 'name')] = TextEditingController(text: yaml['name'].toString());
    controllers[Utils.getFormKeyID(id, 'therapy_ids')] = TextEditingController(text: yaml['therapy_ids'].toString());

    return SFTStrategy(
      id: id,
      name: yaml['name'],
      therapyIds: Utils.extractIntegerList(yaml['therapy_ids'].toString()),
      controllers: controllers,
    );
  }

  @override
  String string() {
    return 'SFTStrategy(name: $name, therapyIds: $therapyIds)';
  }

  @override
  SFTStrategyState createState() => SFTStrategyState();

  @override
  Strategy copy() {
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    therapyIds = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    print('Updated SFTStrategy: $name, therapyIds: $therapyIds');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type,
      'therapy_ids': [therapyIds]
    };
  }
}

class SFTStrategyState extends StrategyState<SFTStrategy> {
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
            widget.strategyForm.StrategySingleTherapyFormField(ref, ref.read(therapyMapProvider.notifier).get(), 'therapy_ids'),
          ],
        ),
      ),
    );
  }
}
