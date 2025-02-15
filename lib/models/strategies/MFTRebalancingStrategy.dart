import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import '../../providers/data_providers.dart';
import '../../utils/utils.dart';
import '../../widgets/yaml_editor/strategies/strategy_detail_card_form.dart';

class MFTRebalancingStrategy extends Strategy {
  late List<int> therapyIds;
  late List<double> distribution;
  late int delayUntilActualTrigger;
  late int updateDurationAfterRebalancing;

  MFTRebalancingStrategy({
    required String id,
    required String name,
    required this.therapyIds,
    required this.distribution,
    required this.delayUntilActualTrigger,
    required this.updateDurationAfterRebalancing,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, type: StrategyType.MFTRebalancing, controllers: controllers);

  factory MFTRebalancingStrategy.fromYaml(dynamic yaml) {
    if (yaml is! Map) {
      throw ArgumentError('Invalid YAML format for MFTRebalancingStrategy');
    }
    if (yaml['name'] == null ||
        yaml['therapy_ids'] == null ||
        yaml['distribution'] == null ||
        yaml['delay_until_actual_trigger'] == null ||
        yaml['update_duration_after_rebalancing'] == null) {
      throw ArgumentError('Missing required fields in YAML for MFTRebalancingStrategy');
    }
    if (yaml['therapy_ids'] is! YamlList || yaml['distribution'] is! YamlList) {
      throw ArgumentError('Invalid format for therapy_ids or distribution in YAML for MFTRebalancingStrategy');
    }
    if (yaml['delay_until_actual_trigger'] is! int) {
      throw ArgumentError('Invalid delay_until_actual_trigger format in YAML for MFTRebalancingStrategy');
    }
    if (yaml['update_duration_after_rebalancing'] is! int) {
      throw ArgumentError('Invalid update_duration_after_rebalancing format in YAML for MFTRebalancingStrategy');
    }
    if (yaml['distribution'].length != yaml['therapy_ids'].length) {
      throw ArgumentError('Distribution length must match therapy_ids length in YAML for MFTRebalancingStrategy');
    }

    String id = Uuid().v4();
    Map<String, TextEditingController> controllers = {};
    controllers[Utils.getFormKeyID(id, 'name')] = TextEditingController(text: yaml['name'].toString());
    controllers[Utils.getFormKeyID(id, 'therapy_ids')] = TextEditingController(text: yaml['therapy_ids'].toString());
    controllers[Utils.getFormKeyID(id, 'distribution')] = TextEditingController(text: yaml['distribution'].toString());
    controllers[Utils.getFormKeyID(id, 'delay_until_actual_trigger')] = TextEditingController(text: yaml['delay_until_actual_trigger'].toString());
    controllers[Utils.getFormKeyID(id, 'update_duration_after_rebalancing')] = TextEditingController(text: yaml['update_duration_after_rebalancing'].toString());

    return MFTRebalancingStrategy(
      id: id,
      name: yaml['name'],
      therapyIds: List<int>.from((yaml['therapy_ids'] as YamlList).toList()),
      distribution: List<double>.from(
          (yaml['distribution'] as YamlList).map((v) => (v as num).toDouble())),
      delayUntilActualTrigger: yaml['delay_until_actual_trigger'],
      updateDurationAfterRebalancing: yaml['update_duration_after_rebalancing'],
      controllers: controllers,
    );
  }

  @override
  String string() {
    return 'MFTRebalancingStrategy(name: $name, therapyIds: $therapyIds, distribution: $distribution, delayUntilActualTrigger: $delayUntilActualTrigger, updateDurationAfterRebalancing: $updateDurationAfterRebalancing)';
  }

  @override
  MFTRebalancingStrategyState createState() => MFTRebalancingStrategyState();

  @override
  Strategy copy() {
    String newId = Uuid().v4();
    Map<String, TextEditingController> newControllers = {};
    newControllers[Utils.getFormKeyID(newId, 'name')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'name')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'therapy_ids')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'distribution')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'distribution')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'delay_until_actual_trigger')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'delay_until_actual_trigger')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'update_duration_after_rebalancing')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'update_duration_after_rebalancing')]!.text);

    return MFTRebalancingStrategy(
      id: newId,
      name: name,
      therapyIds: List<int>.from(therapyIds),
      distribution: List<double>.from(distribution),
      delayUntilActualTrigger: delayUntilActualTrigger,
      updateDurationAfterRebalancing: updateDurationAfterRebalancing,
      controllers: newControllers,
    );
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    therapyIds = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'therapy_ids')]!.text);
    distribution = Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'distribution')]!.text);
    delayUntilActualTrigger = int.parse(controllers[Utils.getFormKeyID(id, 'delay_until_actual_trigger')]!.text);
    updateDurationAfterRebalancing = int.parse(controllers[Utils.getFormKeyID(id, 'update_duration_after_rebalancing')]!.text);
    // print('Updated MFTRebalancingStrategy: $name, therapyIds: $therapyIds, distribution: $distribution, delayUntilActualTrigger: $delayUntilActualTrigger, updateDurationAfterRebalancing: $updateDurationAfterRebalancing');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type.typeAsString,
      'therapy_ids': therapyIds,
      'distribution': distribution,
      'delay_until_actual_trigger': delayUntilActualTrigger,
      'update_duration_after_rebalancing': updateDurationAfterRebalancing,
    };
  }
}

class MFTRebalancingStrategyState extends StrategyState<MFTRebalancingStrategy> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.formWidth * 0.9,
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
                type: StrategyDetailCardFormType.doubleArray,
                controllerKey: 'distribution',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                strategy: widget,
                typeKey: 'therapy_ids',
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
                controllerKey: 'update_duration_after_rebalancing',
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
