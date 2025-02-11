/// therapy_parser.dart
import 'package:yaml/yaml.dart';
import 'therapy.dart';

/// therapy.dart
class Therapy {
  final String name;
  final List<int>? drugIds;
  final List<int>? dosingDays;
  final List<int>? therapyIds;
  final List<int>? regimen;

  Therapy({
    required this.name,
    this.drugIds,
    this.dosingDays,
    this.therapyIds,
    this.regimen,
  });
  factory Therapy.fromYaml(Map<dynamic, dynamic> yaml) {
    return Therapy(
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
    );
  }

  @override
  String toString() {
    return 'Therapy(name: $name, drugIds: $drugIds, dosingDays: $dosingDays, therapyIds: $therapyIds, regimen: $regimen)';
  }
}


class TherapyParser {
  static Map<int, Therapy> parseFromYamlMap(YamlMap yaml) {
    // Verify that the top-level node "therapy_parameters" exists.

    // Parse each therapy entry.
    final Map<int, Therapy> therapies = {};
    yaml.forEach((key, value) {
      // Convert the key (therapy id) to an integer.
      final int id = int.tryParse(key.toString()) ??
          (throw FormatException('Invalid therapy id: $key'));
      therapies[id] = Therapy.fromYaml(value);
    });

    return therapies;
  }

  /// Parses a YAML string into a Map<int, Therapy>.
  static Map<int, Therapy> parseFromString(String yamlString) {
    final dynamic yaml = loadYaml(yamlString);
    if (yaml is! YamlMap) {
      throw FormatException('Provided YAML string is not a valid map.');
    }
    return parseFromYamlMap(yaml);
  }
}
