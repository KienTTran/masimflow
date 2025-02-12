import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

abstract class Config {
  final String id = const Uuid().v4();
  final String name;
  late DateTime date;
  late String value;
  late List<String> yamlKeyList;
  late Map<String, TextEditingController> controllers;
  void updateDate(DateTime date) {
    this.date = date;
  }
  void updateValue(String value) {
    this.value = value;
  }
  void update(){
    if (controllers['date'] != null) {
      controllers['date']?.text = DateFormat('yyyy/MM/dd').format(date);
      updateDate(date);
    }
    if (controllers['value'] != null) {
      controllers['value']?.text = value;
      updateValue(value);
    }
  }

  Config({
    required this.name,
    required this.date,
    required this.value,
    required this.yamlKeyList,
    required this.controllers});
}

class StartingDateConfig extends Config {
  StartingDateConfig({
    required super.name,
    required super.date,
    required super.value,
    required super.yamlKeyList,
    required super.controllers,
  });

  factory StartingDateConfig.fromYaml(Map<dynamic, dynamic> yaml) {
    Map<String,TextEditingController> controllers = {};
    controllers['date'] = TextEditingController(text: yaml['simulation_timeframe']['starting_date']);
    controllers['value'] = TextEditingController(text: yaml['simulation_timeframe']['starting_date']);

    return StartingDateConfig(
      name: 'starting_date',
      date: DateFormat("yyyy/MM/dd").parse(yaml['simulation_timeframe']['starting_date']),
      value: yaml['simulation_timeframe']['starting_date'],
      yamlKeyList: ['simulation_timeframe','starting_date'],
      controllers: controllers,
    );
  }


}

class EndingDateConfig extends Config {
  EndingDateConfig({
    required super.name,
    required super.date,
    required super.value,
    required super.yamlKeyList,
    required super.controllers,
  });

  factory EndingDateConfig.fromYaml(Map<dynamic, dynamic> yaml) {
    Map<String,TextEditingController> controllers = {};
    controllers['date'] = TextEditingController(text: yaml['simulation_timeframe']['ending_date']);
    controllers['value'] = TextEditingController(text: yaml['simulation_timeframe']['ending_date']);

    return EndingDateConfig(
      name: 'ending_date',
      date: DateFormat("yyyy/MM/dd").parse(yaml['simulation_timeframe']['ending_date']),
      value: yaml['simulation_timeframe']['ending_date'],
      yamlKeyList: ['simulation_timeframe','ending_date'],
      controllers: controllers,
    );
  }
}

class StartComparisonDateConfig extends Config {
  StartComparisonDateConfig({
    required super.name,
    required super.date,
    required super.value,
    required super.yamlKeyList,
    required super.controllers,
  });

  factory StartComparisonDateConfig.fromYaml(Map<dynamic, dynamic> yaml) {
    Map<String,TextEditingController> controllers = {};
    controllers['date'] = TextEditingController(text: yaml['simulation_timeframe']['start_of_comparison_period']);
    controllers['value'] = TextEditingController(text: yaml['simulation_timeframe']['start_of_comparison_period']);
    return StartComparisonDateConfig(
      name: 'start_of_comparison_period',
      date: DateFormat("yyyy/MM/dd").parse(yaml['simulation_timeframe']['start_of_comparison_period']),
      value: yaml['simulation_timeframe']['start_of_comparison_period'],
      yamlKeyList: ['simulation_timeframe','start_of_comparison_period'],
      controllers: controllers,
    );
  }
}
