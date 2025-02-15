
import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../utils/utils.dart';
import '../../widgets/yaml_editor/strategies/strategy_detail_card_form.dart';

class MFTStrategy extends Strategy {
  late List<int> therapyIds;
  late List<double>? distribution;

  MFTStrategy({
    required String id,
    required String name,
    required this.therapyIds,
    this.distribution,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, type: StrategyType.MFT, controllers: controllers);

  factory MFTStrategy.fromYaml(dynamic yaml) {
    if (yaml is! Map) {
      throw ArgumentError('Invalid YAML format for MFTStrategy');
    }
    if (yaml['name'] == null || yaml['therapy_ids'] == null) {
      throw ArgumentError('Missing required fields in YAML for MFTStrategy');
    }
    if (yaml['therapy_ids'] is! YamlList) {
      throw ArgumentError('Invalid therapy_ids format in YAML for MFTStrategy');
    }
    if (yaml['distribution'] != null && yaml['distribution'] is! YamlList) {
      throw ArgumentError('Invalid distribution format in YAML for MFTStrategy');
    }
    if (yaml['distribution'] != null && yaml['distribution'].length != yaml['therapy_ids'].length) {
      throw ArgumentError('Distribution length must match therapy_ids length in YAML for MFTStrategy');
    }
    String id = Uuid().v4();
    Map<String, TextEditingController> controllers = {};
    controllers[Utils.getFormKeyID(id, 'name')] = TextEditingController(text: yaml['name'].toString());
    controllers[Utils.getFormKeyID(id, 'therapy_ids')] = TextEditingController(text: yaml['therapy_ids'].toString());
    controllers[Utils.getFormKeyID(id, 'distribution')] = TextEditingController(text: yaml['distribution']?.toString() ?? '');

    return MFTStrategy(
      id: id,
      name: yaml['name'],
      therapyIds: List<int>.from((yaml['therapy_ids'] as YamlList).toList()),
      distribution: yaml['distribution'] != null
          ? List<double>.from(
          (yaml['distribution'] as YamlList).map((v) => (v as num).toDouble()))
          : null,
      controllers: controllers,
    );
  }

  @override
  String string() {
    return 'MFTStrategy(name: $name, therapyIds: $therapyIds, distribution: $distribution)';
  }

  @override
  MFTStrategyState createState() => MFTStrategyState();

  @override
  Strategy copy() {
    String newId = Uuid().v4();
    Map<String, TextEditingController> newControllers = {};
    newControllers[Utils.getFormKeyID(newId, 'name')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'name')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'therapy_ids')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'distribution')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'distribution')]!.text);

    return MFTStrategy(
      id: newId,
      name: controllers[Utils.getFormKeyID(id, 'name')]!.text,
      therapyIds: Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text),
      distribution: Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'distribution')]!.text),
      controllers: newControllers,
    );
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    therapyIds = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    distribution = Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'distribution')]!.text);
    // print('Updated MFTStrategy: $name, therapyIds: $therapyIds, distribution: $distribution');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type.typeAsString,
      'therapy_ids': therapyIds,
      'distribution': distribution
    };
  }
}

class MFTStrategyState extends StrategyState<MFTStrategy> {
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
              strategy: widget,
              width: widget.formWidth * 0.85,
              editable: widget.formEditable,
              controllerKey: 'name'
            ),
            StrategyDetailCardForm(
              type: StrategyDetailCardFormType.multipleTherapy,
              strategy: widget,
              width: widget.formWidth * 0.85,
              editable: widget.formEditable,
              controllerKey: 'therapy_ids',
              therapyMap: ref.read(therapyMapProvider.notifier).get()
            ),
            StrategyDetailCardForm(
              type: StrategyDetailCardFormType.doubleArray,
              strategy: widget,
              width: widget.formWidth * 0.85,
              editable: widget.formEditable,
              controllerKey: 'distribution',
              typeKey: 'therapy_ids',
              lower: 0.0,
              upper: 1.0
            ),
          ],
        ),
      ),
    );
  }
}
