import 'package:flutter/material.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../utils/utils.dart';

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
  }) : super(id: id, name: name, type: 'NestedMFTMultiLocation', controllers: controllers);

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
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  void update() {
    name = controllers[Utils.getFormKeyID(id, 'name')]!.text;
    strategyIds = controllers[Utils.getFormKeyID(id, 'strategy_ids')]!.text
        .replaceAll('[', '').replaceAll(']', '')
        .split(',')
        .map((e) => int.parse(e.trim()))
        .toList();
    startDistributionByLocation.clear();
    peakDistributionByLocation.clear();
    final int locations = 2;
    for(int i = 0; i < 2; i++){
      startDistributionByLocation.add(Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'start_distribution_by_location_$i')]!.text));
      peakDistributionByLocation.add(Utils.extractDoubleList(controllers[Utils.getFormKeyID(id, 'start_distribution_by_location_$i')]!.text));
    }
    peakAfter = int.parse(controllers[Utils.getFormKeyID(id, 'peak_after')]!.text);
    print('Updated NestedMFTMultiLocationStrategy: $name, strategyIds: $strategyIds, startDistributionByLocation: $startDistributionByLocation, peakDistributionByLocation: $peakDistributionByLocation, peakAfter: $peakAfter');
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'type': type,
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
            widget.strategyForm.StrategyIntegerArrayFormField('strategy_ids', lower: 0),
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
                          widget.strategyForm.StrategyDoubleMatrixFormField('start_distribution_by_location_$locationIndex', lower: 0.0, upper: 1.0),
                          widget.strategyForm.StrategyDoubleMatrixFormField('peak_distribution_by_location_$locationIndex', lower: 0.0, upper: 1.0),
                        ]
                      )
                  ),
                ],
              ),
            widget.strategyForm.StrategyIntegerFormField('peak_after', lower: 0),
          ],
        ),
      ),
    );
  }
}
