import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../utils/utils.dart';
import '../../widgets/yaml_editor/strategies/strategy_detail_card_form.dart';

class NestedMFTMultiLocationStrategy extends Strategy {
  late List<int> strategyIds;
  late List<List<double>> startDistributionByLocation;
  late List<List<double>> peakDistributionByLocation;
  late int peakAfter;

  NestedMFTMultiLocationStrategy({
    required String id,
    required String name,
    required this.strategyIds,
    required this.startDistributionByLocation,
    required this.peakDistributionByLocation,
    required this.peakAfter,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, type: StrategyType.NestedMFTMultiLocation, controllers: controllers);

  factory NestedMFTMultiLocationStrategy.fromYaml(dynamic yaml) {
    if (yaml is! Map) {
      throw ArgumentError('Invalid YAML format for NestedMFTMultiLocationStrategy');
    }
    if (yaml['name'] == null ||
        yaml['strategy_ids'] == null ||
        yaml['start_distribution_by_location'] == null ||
        yaml['peak_distribution_by_location'] == null ||
        yaml['peak_after'] == null) {
      throw ArgumentError('Missing required fields in YAML for NestedMFTMultiLocationStrategy');
    }
    if (yaml['strategy_ids'] is! YamlList) {
      throw ArgumentError('Invalid strategy_ids format in YAML for NestedMFTMultiLocationStrategy');
    }
    if (yaml['start_distribution_by_location'] is! YamlList ||
        yaml['peak_distribution_by_location'] is! YamlList) {
      throw ArgumentError('Invalid distribution format in YAML for NestedMFTMultiLocationStrategy');
    }
    if (yaml['start_distribution_by_location'].length != yaml['peak_distribution_by_location'].length) {
      throw ArgumentError('Mismatch in distribution lengths by location for NestedMFTMultiLocationStrategy');
    }
    if (yaml['peak_after'] is! int) {
      throw ArgumentError('Invalid peak_after format in YAML for NestedMFTMultiLocationStrategy');
    }

    String id = Uuid().v4();
    Map<String, TextEditingController> controllers = {};
    controllers[Utils.getFormKeyID(id, 'name')] = TextEditingController(text: yaml['name'].toString());
    controllers[Utils.getFormKeyID(id, 'strategy_ids')] = TextEditingController(text: yaml['strategy_ids'].toString());
    for(int i = 0; i < yaml['start_distribution_by_location'].length; i++){
      controllers[Utils.getFormKeyID(id, 'start_distribution_by_location_$i')] = TextEditingController(text: yaml['start_distribution_by_location'][i].toString());
      controllers[Utils.getFormKeyID(id, 'peak_distribution_by_location_$i')] = TextEditingController(text: yaml['peak_distribution_by_location'][i].toString());
    }
    controllers[Utils.getFormKeyID(id, 'peak_after')] = TextEditingController(text: yaml['peak_after'].toString());

    return NestedMFTMultiLocationStrategy(
      id: id,
      name: yaml['name'],
      strategyIds: List<int>.from((yaml['strategy_ids'] as YamlList).toList()),
      startDistributionByLocation: (yaml['start_distribution_by_location'] as YamlList)
          .map((list) => List<double>.from((list as YamlList).map((v) => (v as num).toDouble())))
          .toList(),
      peakDistributionByLocation: (yaml['peak_distribution_by_location'] as YamlList)
          .map((list) => List<double>.from((list as YamlList).map((v) => (v as num).toDouble())))
          .toList(),
      peakAfter: yaml['peak_after'],
      controllers: controllers,
    );
  }

  @override
  String string() {
    return 'NestedMFTMultiLocationStrategy(name: $name, strategyIds: $strategyIds, startDistributionByLocation: $startDistributionByLocation, peakDistributionByLocation: $peakDistributionByLocation, peakAfter: $peakAfter)';
  }

  @override
  NestedMFTMultiLocationStrategyState createState() => NestedMFTMultiLocationStrategyState();

  @override
  Strategy copy() {
    String newId = Uuid().v4();
    Map<String, TextEditingController> newControllers = {};
    newControllers[Utils.getFormKeyID(newId, 'name')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'name')]!.text);
    newControllers[Utils.getFormKeyID(newId, 'strategy_ids')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'strategy_ids')]!.text);
    for(int i = 0; i < startDistributionByLocation.length; i++){
      newControllers[Utils.getFormKeyID(newId, 'start_distribution_by_location_$i')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'start_distribution_by_location_$i')]!.text);
      newControllers[Utils.getFormKeyID(newId, 'peak_distribution_by_location_$i')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'peak_distribution_by_location_$i')]!.text);
    }
    newControllers[Utils.getFormKeyID(newId, 'peak_after')] = TextEditingController(text: controllers[Utils.getFormKeyID(id, 'peak_after')]!.text);

    return NestedMFTMultiLocationStrategy(
      id: newId,
      name: controllers[Utils.getFormKeyID(id, 'name')]!.text,
      strategyIds: Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'strategy_ids')]!.text),
      startDistributionByLocation: Utils.extractDoubleMatrix(controllers[Utils.getFormKeyID(id, 'start_distribution_by_location')]!.text),
      peakDistributionByLocation: Utils.extractDoubleMatrix(controllers[Utils.getFormKeyID(id, 'peak_distribution_by_location')]!.text),
      peakAfter: int.parse(controllers[Utils.getFormKeyID(id, 'peak_after')]!.text),
      controllers: newControllers,
    );
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    strategyIds = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id, 'strategy_ids')]!.text);
    startDistributionByLocation.clear();
    peakDistributionByLocation.clear();
    final int locations = 2;
    for(int i = 0; i < 2; i++){
      startDistributionByLocation.add(Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'start_distribution_by_location_$i')]!.text));
      peakDistributionByLocation.add(Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'start_distribution_by_location_$i')]!.text));
    }
    peakAfter = int.parse(controllers[Utils.getFormKeyID(id, 'peak_after')]!.text);
    // print('Updated NestedMFTMultiLocationStrategy: $name, strategyIds: $strategyIds, startDistributionByLocation: $startDistributionByLocation, peakDistributionByLocation: $peakDistributionByLocation, peakAfter: $peakAfter');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type.typeAsString,
      'strategy_ids': strategyIds,
      'start_distribution_by_location': startDistributionByLocation,
      'peak_distribution_by_location': peakDistributionByLocation,
      'peak_after': peakAfter,
    };
  }
}

class NestedMFTMultiLocationStrategyState extends StrategyState<NestedMFTMultiLocationStrategy> {
  var locations = 1;
  @override void initState() {
    super.initState();
    locations = widget.startDistributionByLocation.length;
    // if()
  }
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
                strategyParameters: ref.read(strategyParametersProvider.notifier).get(),
                lower: 0.0,
                upper: -1.0,
            ),
            for(int locationIndex = 0; locationIndex < 2; locationIndex++)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location $locationIndex'),
                  Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StrategyDetailCardForm(
                              type: StrategyDetailCardFormType.doubleMatrix,
                              controllerKey: 'start_distribution_by_location_$locationIndex',
                              editable: widget.formEditable,
                              width: widget.formWidth * 0.85,
                              strategy: widget,
                              lower: 0.0,
                              upper: 1.0
                          ),
                          StrategyDetailCardForm(
                              type: StrategyDetailCardFormType.doubleMatrix,
                              controllerKey: 'peak_distribution_by_location_$locationIndex',
                              editable: widget.formEditable,
                              width: widget.formWidth * 0.85,
                              strategy: widget,
                              lower: 0.0,
                              upper: 1.0
                          ),
                        ]
                      )
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
          ],
        ),
      ),
    );
  }
}
