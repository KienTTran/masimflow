/// therapy_parser.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import '../../utils/form_validator.dart';
import '../../utils/utils.dart';
import 'BaseTherapy.dart';
import 'therapy.dart';

class TherapyWidgetRender extends ConsumerStatefulWidget {
  // Constructor
  TherapyWidgetRender({Key? key}) : super(key: key);

  @override
  TherapyWidgetRenderState createState() => TherapyWidgetRenderState();

}

class TherapyWidgetRenderState<T extends TherapyWidgetRender> extends ConsumerState<T> {
  // Override build
  @override
  Widget build(BuildContext context) {
    return Text('TherapyWidgetRender');
  }
}

abstract class TherapyState<T extends Therapy> extends TherapyWidgetRenderState<T> {
  @override
  Widget build(BuildContext context); // Force subclasses to implement build
}

/// therapy.dart
 abstract class Therapy extends TherapyWidgetRender{
  late String id;
  late String name;
  late List<int>? drugIds;
  late List<int>? dosingDays;
  late List<int>? therapyIds;
  late List<int>? regimen;
  late double formWidth;
  bool formEditable = false;
  bool isMAC = false;
  late int initialIndex;
  GlobalKey<ShadFormState> formKey = GlobalKey<ShadFormState>();
  late Map<String, TextEditingController> controllers;
  List<String>? yamlKeyList;
  Therapy copy();

  Therapy({
    required this.id,
    required this.name,
    this.drugIds,
    this.dosingDays,
    this.therapyIds,
    this.regimen,
    this.controllers = const {},
  });

  factory Therapy.fromYaml(Map<dynamic, dynamic> yaml) {
    String id = Uuid().v4();
    Map<String,TextEditingController> controllers = {};
    yaml.forEach((key, value) {
      controllers[Utils.getFormKeyID(id,key.toString())] = TextEditingController(text: value.toString());
    });
    return BaseTherapy(
      id: id,
      name: yaml['name'] as String,
      drugIds: yaml.containsKey('drug_ids')
          ? (yaml['drug_ids'] as List).map((e) => e as int).toList()
          : null,
      dosingDays: yaml.containsKey('dosing_days')
          ? (yaml['dosing_days'] as List).map((e) => e as int).toList()
          : null,
      therapyIds: yaml.containsKey('therapy_ids')
          ? (yaml['therapy_ids'] as List).map((e) => e as int).toList()
          : null,
      regimen: yaml.containsKey('regimen')
          ? (yaml['regimen'] as List).map((e) => e as int).toList()
          : null,
      controllers: controllers,
    );
  }

  String string() {
    return 'Therapy(id: $id, name: $name, drugIds: $drugIds, dosingDays: $dosingDays, therapyIds: $therapyIds, regimen: $regimen)';
  }

  void update(){
    // print('before: $controllers');
    // print('therapy: ${string()}');
    name = controllers[Utils.getFormKeyID(id,'name')]!.text;
    for(final key in controllers.keys){
      if(key.contains('drug_ids')) {
        drugIds = Utils.extractIntegerList(
            controllers[Utils.getFormKeyID(id, 'drug_ids')]!.text);
      }
      if(key.contains('dosing_days')) {
        dosingDays = Utils.extractIntegerList(
            controllers[Utils.getFormKeyID(id, 'dosing_days')]!.text);
      }
      if(key.contains('therapy_ids')){
        therapyIds = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id,'therapy_ids')]!.text);
        print('therapy_ids: $therapyIds');
      }
      if(key.contains('regimen')) {
        regimen = Utils.extractIntegerList(controllers[Utils.getFormKeyID(id,'regimen')]!.text);
        print('regimen: $regimen');
      }
    }
    // print('after: $controllers');
    // print('therapy: ${string()}');
  }

  List<String> getYamlKeyList(){
    return ['therapy_parameters', 'therapy_db', initialIndex.toString()];
  }
  
  Map<String, dynamic> toYamlMap() {
    Map<String,dynamic> yamlMap = {};
    yamlMap['name'] = name;
    if(drugIds != null) yamlMap['drug_ids'] = drugIds;
    if(dosingDays != null) yamlMap['dosing_days'] = dosingDays;
    if(therapyIds != null) yamlMap['therapy_ids'] = therapyIds;
    if(regimen != null) yamlMap['regimen'] = regimen;

    return yamlMap;
  }
}

class TherapyParser {
  static Map<String, Therapy> parseFromYamlMap(YamlMap yaml) {
    // Verify that the top-level node "therapy_parameters" exists.

    // Parse each therapy entry.
    final Map<String, Therapy> therapies = {};
    yaml.forEach((key, value) {
      // Convert the key (therapy id) to an integer.
      final int initialIndex = int.tryParse(key.toString()) ??
          (throw FormatException('Invalid therapy id: $key'));
      Therapy therapy = Therapy.fromYaml(value);
      therapy.initialIndex = initialIndex;
      final id = therapy.id;
      therapies[id] = therapy;
    });
    return therapies;
  }

  /// Parses a YAML string into a Map<String,Therapy>.
  static Map<String, Therapy> parseFromString(String yamlString) {
    final dynamic yaml = loadYaml(yamlString);
    if (yaml is! YamlMap) {
      throw FormatException('Provided YAML string is not a valid map.');
    }
    return parseFromYamlMap(yaml);
  }
}
