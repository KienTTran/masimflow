import 'package:yaml/yaml.dart';

/// Represents a drug with various parameters parsed from YAML.
class Drug {
  final String name;
  final double halfLife;
  final double maximumParasiteKillingRate;
  final int n;
  final List<double> ageSpecificDrugConcentrationSd;
  final List<double>? ageSpecificDrugAbsorption;
  final int k;
  final double baseEC50;

  Drug({
    required this.name,
    required this.halfLife,
    required this.maximumParasiteKillingRate,
    required this.n,
    required this.ageSpecificDrugConcentrationSd,
    this.ageSpecificDrugAbsorption,
    required this.k,
    required this.baseEC50,
  });

  /// Factory constructor to create a [Drug] from a YAML node.
  ///
  /// The [yaml] parameter should be a map representing a single drug's data.
  factory Drug.fromYaml(Map<dynamic, dynamic> yaml) {
    return Drug(
      name: yaml['name'] as String,
      halfLife: (yaml['half_life'] as num).toDouble(),
      maximumParasiteKillingRate:
      (yaml['maximum_parasite_killing_rate'] as num).toDouble(),
      n: yaml['n'] as int,
      ageSpecificDrugConcentrationSd: (yaml['age_specific_drug_concentration_sd'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      ageSpecificDrugAbsorption: yaml.containsKey('age_specific_drug_absorption')
          ? (yaml['age_specific_drug_absorption'] as List)
          .map((e) => (e as num).toDouble())
          .toList()
          : null,
      k: yaml['k'] as int,
      baseEC50: (yaml['base_EC50'] as num).toDouble()
    );
  }

  @override
  String toString() {
    return 'Drug(name: $name, halfLife: $halfLife, maximumParasiteKillingRate: $maximumParasiteKillingRate, n: $n, ageSpecificDrugConcentrationSd: $ageSpecificDrugConcentrationSd, ageSpecificDrugAbsorption: $ageSpecificDrugAbsorption, k: $k, baseEC50: $baseEC50)';
  }
}

class DrugParser {
  /// Throws a [FormatException] if the expected nodes are missing.
  static Map<int, Drug> parseFromYamlMap(YamlMap yaml) {
    // Parse each drug entry.
    final Map<int, Drug> drugs = {};
    yaml.forEach((key, value) {
      // The key should be convertible to an int.
      final int id = int.tryParse(key.toString()) ??
          (throw FormatException('Invalid drug id: $key'));
      // Parse each drug using the Drug.fromYaml factory constructor.
      drugs[id] = Drug.fromYaml(value);
    });

    return drugs;
  }

  /// Parses a YAML string into a [Map<int, Drug>].
  ///
  /// The [yamlString] should contain the YAML data with the expected structure.
  static Map<int, Drug> parseFromString(String yamlString) {
    // Load the YAML string into a YamlMap.
    final dynamic yaml = loadYaml(yamlString);
    if (yaml is! YamlMap) {
      throw FormatException('The provided YAML string does not contain a valid YAML map.');
    }
    return parseFromYamlMap(yaml);
  }
}
