
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import '../../widgets/yaml_editor/events/event_detail_card_form.dart';
import 'ChangeInterruptedFeedingRate.dart';
import 'ChangeMutationProbabilityPerLocus.dart';
import 'ChangeTreatmentCoverage.dart';
import 'ChangeTreatmentStrategy.dart';
import 'ChangeWithinHostInducedRecombination.dart';
import 'Introduce580YParasites.dart';
import 'IntroduceAQMutantParasites.dart';
import 'IntroduceLumefantrineMutantParasites.dart';
import 'IntroduceParasites.dart';
import 'IntroduceParasitesPeriodically.dart';
import 'IntroducePlas2Parasites.dart';
import 'IntroduceTripleMutantToDPMParasites.dart';
import 'ModifyNestMFTStrategy.dart';
import 'SingleRoundMDA.dart';
import 'TurnOnOffMutation.dart';

class EventWidgetRender extends ConsumerStatefulWidget {
  // Constructor
  EventWidgetRender({Key? key}) : super(key: key);

  @override
  EventWidgetRenderState createState() => EventWidgetRenderState();
}

class EventWidgetRenderState<T extends EventWidgetRender> extends ConsumerState<T> {
  // Override build
  @override
  Widget build(BuildContext context) {
    return Text('EventWidgetRender');
  }
}

abstract class EventState<T extends Event> extends EventWidgetRenderState<T> {
  @override
  Widget build(BuildContext context); // Force subclasses to implement build
}

abstract class Event extends EventWidgetRender {
  final String id;
  final String name;
  final Map<String, TextEditingController> controllers;
  GlobalKey<ShadFormState> formKey = GlobalKey<ShadFormState>();
  late EventDetailCardForm eventForm;

  Event({
    required this.id,
    required this.name,
    required this.controllers
  }) : super(key: Key(id));

  Map<String, dynamic> toYamlMap();
  Event copy();
  void update();
  void addEntry();
  void deleteEntry();

  List<DateTime> dates() {
    List<DateTime> dates = [];
    for (var key in controllers.keys) {
      if (key.contains('date')) {
        dates.add(DateFormat('yyyy/MM/dd').parse(controllers[key]!.text));
      }
    }
    return dates;
  }

  List<dynamic> values() {
    List<dynamic> values = [];
    for (var key in controllers.keys) {
      if (key.contains('value')) {
        values.add(controllers[key]!.text);
      }
    }
    return values;
  }

  List<dynamic> valuesByKey(String key) {
    List<dynamic> values = [];
    for (var cKey in controllers.keys) {
      if (cKey.contains(key)) {
        values.add(controllers[cKey]!.text);
      }
    }
    return values;
  }

  dynamic value() {
    return values().first;
  }

  dynamic controllerValue(String key) {
    return controllers[key]?.value;
  }

  dynamic controllerText(String key) {
    return controllers[key]?.text;
  }

  factory Event.fromYaml(Map<dynamic, dynamic> yaml) {
    switch (yaml['name']) {
      case 'change_within_host_induced_recombination':
        return ChangeWithinHostInducedRecombination.fromYaml(yaml);
      case 'change_mutation_probability_per_locus':
        return ChangeMutationProbabilityPerLocus.fromYaml(yaml);
      case 'turn_off_mutation':
        return TurnOffMutation.fromYaml(yaml);
      case 'turn_on_mutation':
        return TurnOnMutation.fromYaml(yaml);
      case 'change_treatment_coverage':
        return ChangeTreatmentCoverage.fromYaml(yaml);
      case 'change_treatment_strategy':
        return ChangeTreatmentStrategy.fromYaml(yaml);
      case 'single_round_MDA':
        return SingleRoundMDA.fromYaml(yaml);
      case 'modify_nested_mft_strategy':
        return ModifyNestedMFTStrategy.fromYaml(yaml);
      case 'introduce_plas2_parasites':
        return IntroducePlas2Parasites.fromYaml(yaml);
      case 'introduce_parasites':
        return IntroduceParasites.fromYaml(yaml);
      case 'introduce_parasites_periodically':
        return IntroduceParasitesPeriodically.fromYaml(yaml);
      case 'introduce_580Y_parasites':
        return Introduce580YParasites.fromYaml(yaml);
      case 'introduce_aq_mutant_parasites':
        return IntroduceAQMutantParasites.fromYaml(yaml);
      case 'introduce_lumefantrine_mutant_parasites':
        return IntroduceLumefantrineMutantParasites.fromYaml(yaml);
      case 'introduce_triple_mutant_to_dpm_parasites':
        return IntroduceTripleMutantToDPMParasites.fromYaml(yaml);
      case 'change_interrupted_feeding_rate':
        return ChangeInterruptedFeedingRate.fromYaml(yaml);
      default:
        throw Exception('Unknown event type: ${yaml['name']}');
    }
  }
}

class EventParser {
  /// Parses a YAML string into a list of Event objects.
  static List<Event> fromYamlString(String yamlString) {
    final yamlMap = loadYaml(yamlString);
    return fromYamlMap(yamlMap);
  }

  /// Parses a YamlMap into a list of Event objects.
  static List<Event> fromYamlMap(YamlMap yamlMap) {
    final List eventsList = yamlMap['population_events'] as List;
    return eventsList
        .map((e) => Event.fromYaml(e as Map<dynamic, dynamic>))
        .toList();
  }

  /// Asynchronously reads the YAML file from assets/config/events.yaml,
  /// then parses and returns the list of Event objects.
  static Future<List<Event>> fromAssets(String path) async {
    final String yamlString = await rootBundle.loadString(path);
    return fromYamlString(yamlString);
  }
}

class BaseEvent extends Event {
  BaseEvent({
    required super.id,
    required super.name,
    required super.controllers,
  });

  factory BaseEvent.fromYaml(Map<dynamic, dynamic> yaml) {
    return BaseEvent(
      id: const Uuid().v4(),
      name: '',
      controllers: {},
    );
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {};
  }

  @override
  Event copy() {
    return BaseEvent(
      id: const Uuid().v4(),
      name: '',
      controllers: {},
    );
  }

  @override
  void update() {
  }

  @override
  void addEntry() {
  }

  @override
  void deleteEntry() {
  }
}


