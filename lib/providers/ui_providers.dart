import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoolResetProvider extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> set(bool value) async {
    state = value;
    if(state){
      await Future.delayed(Duration(milliseconds: 200));
      state = false;
    }

  }

  bool get() {
    return state;
  }

  void update() {
    set(true);
  }
}

final updateUIProvider = NotifierProvider<BoolResetProvider, bool>(() {
  return BoolResetProvider();
});


class BoolProvider extends Notifier<bool> {
  @override
  bool build() {
    return true;
  }

  Future<void> set(bool value) async {
    state = value;
  }

  bool get() {
    return state;
  }
}

final allFormsAreValidatedProvider = NotifierProvider<BoolProvider, bool>(() {
  return BoolProvider();
});



class DoubleMapProvider extends Notifier<Map<String,double>> {
  @override
  Map<String,double> build() {
    return {};
  }

  void setValue(String key,double value) {
    state[key] = value;
  }

  void set(Map<String,double> value) {
    state = value;
  }

  Map<String,double> get() {
    return state;
  }

  double getValue(String key) {
    return state[key] ?? 0.0;
  }
}

final panelWidthMapProvider = NotifierProvider<DoubleMapProvider, Map<String,double>>(() {
  return DoubleMapProvider();
});

class IntListProvider extends Notifier<List<int>> {
  @override
  List<int> build() {
    return [];
  }

  void add(int value) {
    state.add(value);
  }

  void set(List<int> value) {
    state = value;
  }

  List<int> get() {
    return state;
  }

  void remove(int value) {
    state.remove(value);
  }
}

final therapyIdsProvider = NotifierProvider<IntListProvider, List<int>>(() {
  return IntListProvider();
});