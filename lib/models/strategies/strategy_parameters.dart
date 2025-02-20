import 'package:masimflow/models/strategies/strategy.dart';
import 'package:yaml/yaml.dart';

/// Parses the given YAML string and returns a StrategyParameters instance.
StrategyParameters parseYamlString(String yamlString) {
  final doc = loadYaml(yamlString);
  return StrategyParameters.fromYaml(doc);
}

/// Holds all strategy parameters from the YAML.
class StrategyParameters {
  final Map<int, Strategy> strategyDb;
  late int initialStrategyId;
  final int recurrentTherapyId;
  final MassDrugAdministration massDrugAdministration;

  StrategyParameters({
    required this.strategyDb,
    required this.initialStrategyId,
    required this.recurrentTherapyId,
    required this.massDrugAdministration,
  });

  factory StrategyParameters.fromYaml(dynamic yaml) {
    // "strategy_parameters" is the root node.
    final strategyParams = yaml['strategy_parameters'];
    // Parse the strategy_db map.
    final Map<int, Strategy> strategyDb = {};
    (strategyParams['strategy_db'] as YamlMap).forEach((key, value) {
      // Convert the key (which might be a string) to int.
      int intKey = int.parse(key.toString());
      try {
        strategyDb[intKey] = Strategy.fromYaml(value);
      }
      catch (e) {
        print('Error parsing strategy with key $intKey: $e');
      }
    });

    return StrategyParameters(
      strategyDb: strategyDb,
      initialStrategyId: strategyParams['initial_strategy_id'],
      recurrentTherapyId: strategyParams['recurrent_therapy_id'],
      massDrugAdministration:
      MassDrugAdministration.fromYaml(strategyParams['mass_drug_administration']),
    );
  }

  List<Strategy> get strategies {
    return strategyDb.values.toList();
  }

  @override
  String toString() {
    return 'StrategyParameters(\n'
        '  strategyDb: $strategyDb,\n'
        '  initialStrategyId: $initialStrategyId,\n'
        '  recurrentTherapyId: $recurrentTherapyId,\n'
        '  massDrugAdministration: $massDrugAdministration\n'
        ')';
  }
}

/// Holds the mass drug administration settings.
class MassDrugAdministration {
  final bool enable;
  final int mdaTherapyId;
  final List<int> ageBracketProbIndividualPresentAtMDA;
  final List<double> meanProbIndividualPresentAtMDA;
  final List<double> sdProbIndividualPresentAtMDA;

  MassDrugAdministration({
    required this.enable,
    required this.mdaTherapyId,
    required this.ageBracketProbIndividualPresentAtMDA,
    required this.meanProbIndividualPresentAtMDA,
    required this.sdProbIndividualPresentAtMDA,
  });

  factory MassDrugAdministration.fromYaml(dynamic yaml) {
    return MassDrugAdministration(
      enable: yaml['enable'],
      mdaTherapyId: yaml['mda_therapy_id'],
      ageBracketProbIndividualPresentAtMDA: List<int>.from(
          (yaml['age_bracket_prob_individual_present_at_mda'] as YamlList).toList()),
      meanProbIndividualPresentAtMDA: (yaml['mean_prob_individual_present_at_mda'] as YamlList)
          .map((v) => (v as num).toDouble())
          .toList(),
      sdProbIndividualPresentAtMDA: (yaml['sd_prob_individual_present_at_mda'] as YamlList)
          .map((v) => (v as num).toDouble())
          .toList(),
    );
  }

  @override
  String toString() {
    return 'MassDrugAdministration('
        'enable: $enable, '
        'mdaTherapyId: $mdaTherapyId, '
        'ageBracketProbIndividualPresentAtMDA: $ageBracketProbIndividualPresentAtMDA, '
        'meanProbIndividualPresentAtMDA: $meanProbIndividualPresentAtMDA, '
        'sdProbIndividualPresentAtMDA: $sdProbIndividualPresentAtMDA'
        ')';
  }
}
