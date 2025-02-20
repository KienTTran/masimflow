
import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../utils/utils.dart';
import '../../widgets/yaml_editor/strategies/strategy_detail_card_form.dart';

class SFTStrategy extends Strategy {
  late List<int> therapyIds;

  SFTStrategy({
    required String id,
    required String name,
    required this.therapyIds,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, type: StrategyType.SFT, controllers: controllers);

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
    String newId = Uuid().v4();
    Map<String, TextEditingController> newControllers = {};
    newControllers[Utils.getFormKeyID(newId, 'name')] = TextEditingController(text: name);
    newControllers[Utils.getFormKeyID(newId, 'therapy_ids')] = TextEditingController(text: therapyIds.toString());
    return SFTStrategy(id: newId, name: name, therapyIds: therapyIds, controllers: newControllers);
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    therapyIds = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    // print('Updated SFTStrategy: $name, therapyIds: $therapyIds');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type.typeAsString,
      'therapy_ids': therapyIds
    };
  }
}

class SFTStrategyState extends StrategyState<SFTStrategy> {
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
                type: StrategyDetailCardFormType.singleTherapy,
                controllerKey: 'therapy_ids',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                strategy: widget,
                therapyMap: ref.read(therapyTemplateMapProvider.notifier).get()
            ),
          ],
        ),
      ),
    );
  }
}
