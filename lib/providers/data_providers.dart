import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter/material.dart';

import '../models/drugs/drug.dart';
import '../models/events/event.dart';
import '../models/markers/config_marker.dart';
import '../models/markers/event_marker.dart';
import '../models/markers/strategy_marker.dart';
import '../models/strategies/strategy.dart';
import '../models/strategies/strategy_parameters.dart';
import '../models/therapies/therapy.dart';

class EventMapProvider extends Notifier<Map<String,Event>> {

  void set(Map<String,Event> data) {
    state = data;
  }

  Map<String,Event> get() {
    return state;
  }

  void setEvent(String id, Event event) {
    state[id] = event;
  }

  Event? getEvent(String id) {
    return state[id];
  }

  void clear() {
    state.clear();
  }

  void deleteEventID(String id) {
    state.remove(id);
  }

  @override
  build() {
    return {};
  }
}

final eventTemplateMapProvider = NotifierProvider<EventMapProvider, Map<String,Event>>(() {
  return EventMapProvider();
});

final eventDisplayMapProvider = NotifierProvider<EventMapProvider, Map<String,Event>>(() {
  return EventMapProvider();
});

class StrategyMapProvider extends Notifier<Map<String,Strategy>> {
  void set(Map<String,Strategy> data) {
    state = data;
  }

  Map<String,Strategy> get() {
    return state;
  }

  void setStrategy(String id, Strategy strategy) {
    state[id] = strategy;
  }

  Strategy? getStrategy(String id) {
    return state[id];
  }

  void clear() {
    state.clear();
  }

  void deleteStrategyID(String id) {
    state.remove(id);
  }

  @override
  build() {
    return {};
  }
}

final strategyTemplateMapProvider = NotifierProvider<StrategyMapProvider, Map<String,Strategy>>(() {
  return StrategyMapProvider();
});

final strategyDisplayMapProvider = NotifierProvider<StrategyMapProvider, Map<String,Strategy>>(() {
  return StrategyMapProvider();
});

class ConfigMarkerListNotifier extends Notifier<List<ConfigMarker>> {

  void set(List<ConfigMarker> markers) {
    state = markers;
  }

  List<ConfigMarker> get() {
    return state;
  }

  void add(ConfigMarker marker) {
    state.add(marker);
  }

  void delete(ConfigMarker marker) {
    state.remove(marker);
  }

  void update(ConfigMarker marker) {
    state[state.indexWhere((element) => element.id == marker.id)] = marker;
  }

  @override
  build() {
    return [];
  }
}

final configMarkerListProvider = NotifierProvider<ConfigMarkerListNotifier, List<ConfigMarker>>(() {
  return ConfigMarkerListNotifier();
});

class EventMarkerListNotifier extends Notifier<List<EventMarker>> {

  void set(List<EventMarker> markers) {
    state = markers;
  }

  List<EventMarker> get() {
    return state;
  }

  void add(EventMarker marker) {
    state.add(marker);
  }

  void delete(EventMarker marker) {
    state.remove(marker);
  }

  void deleteEventID(String id) {
    state.removeWhere((marker) => marker.event.id == id);
  }

  @override
  build() {
    return [];
  }
}

final eventMarkerListProvider = NotifierProvider<EventMarkerListNotifier, List<EventMarker>>(() {
  return EventMarkerListNotifier();
});


class StrategyMarkerListNotifier extends Notifier<List<StrategyMarker>> {

  void set(List<StrategyMarker> markers) {
    state = markers;
  }

  List<StrategyMarker> get() {
    return state;
  }

  void add(StrategyMarker marker) {
    state.add(marker);
  }

  void delete(StrategyMarker marker) {
    state.remove(marker);
  }

  @override
  build() {
    return [];
  }
}

final strategyMarkerListProvider = NotifierProvider<StrategyMarkerListNotifier, List<StrategyMarker>>(() {
  return StrategyMarkerListNotifier();
});

class DrugMapNotifier extends Notifier<Map<String,Drug>> {

  void set(Map<String,Drug> data) {
    state = data;
  }

  Map<String,Drug> get() {
    return state;
  }

  void setDrug(String id, Drug drug) {
    state[id] = drug;
  }

  Drug? getDrug(String id) {
    return state[id];
  }

  @override
  build() {
    return {};
  }
}

final drugMapProvider = NotifierProvider<DrugMapNotifier, Map<String,Drug>>(() {
  return DrugMapNotifier();
});


class TherapyMapProvider extends Notifier<Map<String,Therapy>> {
  void set(Map<String,Therapy> data) {
    state = data;
  }

  Map<String,Therapy> get() {
    return state;
  }

  void setTherapy(String id, Therapy therapy) {
    state[id] = therapy;
  }

  Therapy? getTherapy(String id) {
    return state[id];
  }

  Therapy? getTherapyByIndex(int index) {
    return state.values.elementAt(index);
  }

  void clear() {
    state.clear();
  }

  void deleteTherapyID(String id) {
    state.remove(id);
  }

  @override
  build() {
    return {};
  }
}

final therapyTemplateMapProvider = NotifierProvider<TherapyMapProvider, Map<String,Therapy>>(() {
  return TherapyMapProvider();
});

final therapyDisplayMapProvider = NotifierProvider<TherapyMapProvider, Map<String,Therapy>>(() {
  return TherapyMapProvider();
});


class StrategyParametersNotifier extends Notifier<StrategyParameters> {

  void set(StrategyParameters data) {
    state = data;
  }

  StrategyParameters get() {
    return state;
  }

  @override
  build() {
    return StrategyParameters(
      strategyDb: {},
      initialStrategyId: 0,
      recurrentTherapyId: 0,
      massDrugAdministration: MassDrugAdministration(
        enable: false,
        mdaTherapyId: 0,
        meanProbIndividualPresentAtMDA: [],
        sdProbIndividualPresentAtMDA: [], 
        ageBracketProbIndividualPresentAtMDA: [],
      ),
    );
  }
}

final strategyParametersProvider = NotifierProvider<StrategyParametersNotifier, StrategyParameters>(() {
  return StrategyParametersNotifier();
});


class DateMapNotifier extends Notifier<Map<String, DateTime>> {

  void setDate(String key, DateTime date) {
    state[key] = date;
  }

  void set(Map<String, DateTime> data) {
    state = data;
  }

  Map<String, DateTime> get() {
    return state;
  }

  DateTime? getDate(String key) {
    return state[key];
  }

  @override
  build() {
    return {};
  }
}

final dateMapProvider = NotifierProvider<DateMapNotifier, Map<String, DateTime>>(() {
  return DateMapNotifier();
});

class MapProvider extends Notifier<Map<String, dynamic>> {

  void set(String key, dynamic value) {
    state[key] = value;
  }

  void setMap(Map<String, dynamic> data) {
    state = data;
  }

  Map<String, dynamic> get() {
    return state;
  }

  @override
  build() {
    return {};
  }
}

final configKeyMapProvider = NotifierProvider<MapProvider, Map<String, dynamic>>(() {
  return MapProvider();
});

class ConfigYamlFileNotifier extends Notifier<YamlMap> {
  String fileName = '';
  Map<dynamic, dynamic> mutYamlMap = {};
  void set(YamlMap yamlMap) {
    state = yamlMap;
    mutYamlMap = Map.from(yamlMap);
  }

  void setFileName(String name) {
    fileName = name;
  }

  Map<dynamic, dynamic> getMutYamlMap() {
    return mutYamlMap;
  }

  /// Recursively converts an immutable [Map] (and any nested maps) into mutable ones.
  Map _toMutableMapUpdateOrAppend(Map original) {
    Map mutableMap = {};
    original.forEach((key, value) {
      var newKey = key.toString(); // Ensure the key is treated as a string
      if (value is Map) {
        mutableMap[newKey] = _toMutableMapUpdateOrAppend(value);
      } else if (value is List) {
        mutableMap[newKey] = value.map((item) {
          return (item is Map) ? _toMutableMapUpdateOrAppend(item) : item;
        }).toList();
      } else {
        mutableMap[newKey] = value;
      }
    });
    return mutableMap;
  }

  /// Updates or inserts a value in the YAML map at the location specified by [keyList].
  /// If the target node is a list, it appends [value] instead of replacing it.
  void updateYamlValueByKeyList(List<String> keyList, dynamic value, {bool append = false}) {
    // print('updateYamlValueByKeyList: keyList = $keyList, value = $value, append = $append');

    if (keyList.isEmpty) {
      throw ArgumentError('The key list cannot be empty');
    }

    // Convert the top-level YAML map into a mutable structure.
    Map mutableYamlMap = _toMutableMapUpdateOrAppend(mutYamlMap);

    // Traverse the map using the keys, stopping one level before the final key.
    Map currentMap = mutableYamlMap;
    for (int i = 0; i < keyList.length - 1; i++) {
      String key = keyList[i].toString();

      // If the key does not exist or is not a map, create a new empty map.
      if (!currentMap.containsKey(key) || currentMap[key] is! Map) {
        currentMap[key] = {};
      }

      // Move one level deeper.
      currentMap = currentMap[key];
    }

    // Ensure the last key is treated as a string.
    String lastKey = keyList.last.toString();

    if (append) {
      // If the key exists and is already a list, append the value.
      if (currentMap.containsKey(lastKey) && currentMap[lastKey] is List) {
        currentMap[lastKey].add(value);
      } else {
        // If the key does not exist or is not a list, create a new list.
        currentMap[lastKey] = [value];
      }
    } else {
      // Overwrite existing value if not appending.
      currentMap[lastKey] = value;
    }

    // Assign the updated map back to your global variable.
    mutYamlMap = mutableYamlMap;

    // print('Updated YAML map: ${currentMap[lastKey]}');
  }

  Map getStrategiesByType() {
    final strategies = {};
    final strategyDb = mutYamlMap['strategy_parameters']['strategy_db'];
    for (var i = 0; i < strategyDb.length; i++) {
      final strategy = strategyDb[i];
      final type = strategy['type'];
      strategies[type] = [];
    }
    for (var i = 0; i < strategyDb.length; i++) {
      final strategy = strategyDb[i];
      final type = strategy['type'];
      strategies[type].add(strategy);
    }
    print('getStrategiesByType $strategies');
    return strategies;
  }

  @override
  build() {
    state = YamlMap.wrap({});
    return state;
  }
}

final configYamlFileProvider = NotifierProvider<ConfigYamlFileNotifier, YamlMap>(() {
  return ConfigYamlFileNotifier();
});

class StrategyProvider extends Notifier<Strategy> {

  void set(Strategy strategy) {
    state = strategy;
  }

  Strategy get() {
    return state;
  }

  @override
  build() {
    return BaseStrategy(
        id: Uuid().v4(),
        name: 'Base Strategy',
        type: StrategyType.Base,
        controllers: {});
  }
}

final initialStrategyProvider = NotifierProvider<StrategyProvider, Strategy>(() {
  return StrategyProvider();
});
