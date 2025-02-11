import 'package:yaml/yaml.dart';

/// Base (abstract) class for a strategy.
abstract class Strategy {
  final String name;
  final String type;

  Strategy({required this.name, required this.type});

  /// Factory constructor to choose the correct concrete subclass
  /// based on the YAML “type” field.
  factory Strategy.fromYaml(dynamic yaml) {
    final String strategyType = yaml['type'];
    switch (strategyType) {
      case 'MFT':
        return MFTStrategy.fromYaml(yaml);
      case 'SFT':
        return SFTStrategy.fromYaml(yaml);
      case 'Cycling':
        return CyclingStrategy.fromYaml(yaml);
      case 'AdaptiveCycling':
        return AdaptiveCyclingStrategy.fromYaml(yaml);
      case 'MFTRebalancing':
        return MFTRebalancingStrategy.fromYaml(yaml);
      case 'NestedMFT':
        return NestedMFTStrategy.fromYaml(yaml);
      case 'NestedMFTMultiLocation':
        return NestedMFTMultiLocationStrategy.fromYaml(yaml);
      default:
        throw Exception("Unknown strategy type: $strategyType");
    }
  }

  @override
  String toString() => 'Strategy(name: $name, type: $type)';
}

/// Strategy for type “MFT” (e.g. keys 0 and 5).
class MFTStrategy extends Strategy {
  final List<int> therapyIds;
  final List<double>? distribution;

  MFTStrategy({
    required String name,
    required this.therapyIds,
    this.distribution,
  }) : super(name: name, type: 'MFT');

  factory MFTStrategy.fromYaml(dynamic yaml) {
    return MFTStrategy(
      name: yaml['name'],
      therapyIds: List<int>.from((yaml['therapy_ids'] as YamlList).toList()),
      distribution: yaml['distribution'] != null
          ? List<double>.from(
          (yaml['distribution'] as YamlList).map((v) => (v as num).toDouble()))
          : null,
    );
  }

  @override
  String toString() {
    return 'MFTStrategy(name: $name, therapyIds: $therapyIds, distribution: $distribution)';
  }
}

/// Strategy for type “SFT” (e.g. keys 1, 2, 9, 10, 14, 15).
class SFTStrategy extends Strategy {
  final List<int> therapyIds;

  SFTStrategy({
    required String name,
    required this.therapyIds,
  }) : super(name: name, type: 'SFT');

  factory SFTStrategy.fromYaml(dynamic yaml) {
    return SFTStrategy(
      name: yaml['name'],
      therapyIds: List<int>.from((yaml['therapy_ids'] as YamlList).toList()),
    );
  }

  @override
  String toString() {
    return 'SFTStrategy(name: $name, therapyIds: $therapyIds)';
  }
}

/// Strategy for type “Cycling” (e.g. key 3).
class CyclingStrategy extends Strategy {
  final List<int> therapyIds;
  final int cyclingTime;

  CyclingStrategy({
    required String name,
    required this.therapyIds,
    required this.cyclingTime,
  }) : super(name: name, type: 'Cycling');

  factory CyclingStrategy.fromYaml(dynamic yaml) {
    return CyclingStrategy(
      name: yaml['name'],
      therapyIds: List<int>.from((yaml['therapy_ids'] as YamlList).toList()),
      cyclingTime: yaml['cycling_time'],
    );
  }

  @override
  String toString() {
    return 'CyclingStrategy(name: $name, therapyIds: $therapyIds, cyclingTime: $cyclingTime)';
  }
}

/// Strategy for type “AdaptiveCycling” (e.g. key 4).
class AdaptiveCyclingStrategy extends Strategy {
  final List<int> therapyIds;
  final double triggerValue;
  final int delayUntilActualTrigger;
  final int turnOffDays;

  AdaptiveCyclingStrategy({
    required String name,
    required this.therapyIds,
    required this.triggerValue,
    required this.delayUntilActualTrigger,
    required this.turnOffDays,
  }) : super(name: name, type: 'AdaptiveCycling');

  factory AdaptiveCyclingStrategy.fromYaml(dynamic yaml) {
    return AdaptiveCyclingStrategy(
      name: yaml['name'],
      therapyIds: List<int>.from((yaml['therapy_ids'] as YamlList).toList()),
      triggerValue: (yaml['trigger_value'] as num).toDouble(),
      delayUntilActualTrigger: yaml['delay_until_actual_trigger'],
      turnOffDays: yaml['turn_off_days'],
    );
  }

  @override
  String toString() {
    return 'AdaptiveCyclingStrategy(name: $name, therapyIds: $therapyIds, triggerValue: $triggerValue, delayUntilActualTrigger: $delayUntilActualTrigger, turnOffDays: $turnOffDays)';
  }
}

/// Strategy for type “MFTRebalancing” (e.g. keys 6, 7, 8).
class MFTRebalancingStrategy extends Strategy {
  final List<int> therapyIds;
  final List<double> distribution;
  final int delayUntilActualTrigger;
  final int updateDurationAfterRebalancing;

  MFTRebalancingStrategy({
    required String name,
    required this.therapyIds,
    required this.distribution,
    required this.delayUntilActualTrigger,
    required this.updateDurationAfterRebalancing,
  }) : super(name: name, type: 'MFTRebalancing');

  factory MFTRebalancingStrategy.fromYaml(dynamic yaml) {
    return MFTRebalancingStrategy(
      name: yaml['name'],
      therapyIds: List<int>.from((yaml['therapy_ids'] as YamlList).toList()),
      distribution: List<double>.from(
          (yaml['distribution'] as YamlList).map((v) => (v as num).toDouble())),
      delayUntilActualTrigger: yaml['delay_until_actual_trigger'],
      updateDurationAfterRebalancing: yaml['update_duration_after_rebalancing'],
    );
  }

  @override
  String toString() {
    return 'MFTRebalancingStrategy(name: $name, therapyIds: $therapyIds, distribution: $distribution, delayUntilActualTrigger: $delayUntilActualTrigger, updateDurationAfterRebalancing: $updateDurationAfterRebalancing)';
  }
}

/// Strategy for type “NestedMFT” (e.g. keys 11 and 12).
class NestedMFTStrategy extends Strategy {
  final List<int> strategyIds;
  final List<double> startDistribution;
  final List<double> peakDistribution;
  final int peakAfter;

  NestedMFTStrategy({
    required String name,
    required this.strategyIds,
    required this.startDistribution,
    required this.peakDistribution,
    required this.peakAfter,
  }) : super(name: name, type: 'NestedMFT');

  factory NestedMFTStrategy.fromYaml(dynamic yaml) {
    return NestedMFTStrategy(
      name: yaml['name'],
      strategyIds: List<int>.from((yaml['strategy_ids'] as YamlList).toList()),
      startDistribution: List<double>.from(
          (yaml['start_distribution'] as YamlList)
              .map((v) => (v as num).toDouble())),
      peakDistribution: List<double>.from(
          (yaml['peak_distribution'] as YamlList)
              .map((v) => (v as num).toDouble())),
      peakAfter: yaml['peak_after'],
    );
  }

  @override
  String toString() {
    return 'NestedMFTStrategy(name: $name, strategyIds: $strategyIds, startDistribution: $startDistribution, peakDistribution: $peakDistribution, peakAfter: $peakAfter)';
  }
}

/// Strategy for type “NestedMFTMultiLocation” (e.g. key 13).
class NestedMFTMultiLocationStrategy extends Strategy {
  final List<int> strategyIds;
  final List<List<double>> startDistributionByLocation;
  final List<List<double>> peakDistributionByLocation;
  final int peakAfter;

  NestedMFTMultiLocationStrategy({
    required String name,
    required this.strategyIds,
    required this.startDistributionByLocation,
    required this.peakDistributionByLocation,
    required this.peakAfter,
  }) : super(name: name, type: 'NestedMFTMultiLocation');

  factory NestedMFTMultiLocationStrategy.fromYaml(dynamic yaml) {
    List<List<double>> parseNestedList(YamlList yamlList) {
      return yamlList
          .map((e) => List<double>.from(
          (e as YamlList).map((v) => (v as num).toDouble())))
          .toList();
    }

    return NestedMFTMultiLocationStrategy(
      name: yaml['name'],
      strategyIds: List<int>.from((yaml['strategy_ids'] as YamlList).toList()),
      startDistributionByLocation:
      parseNestedList(yaml['start_distribution_by_location'] as YamlList),
      peakDistributionByLocation:
      parseNestedList(yaml['peak_distribution_by_location'] as YamlList),
      peakAfter: yaml['peak_after'],
    );
  }

  @override
  String toString() {
    return 'NestedMFTMultiLocationStrategy(name: $name, strategyIds: $strategyIds, startDistributionByLocation: $startDistributionByLocation, peakDistributionByLocation: $peakDistributionByLocation, peakAfter: $peakAfter)';
  }
}
