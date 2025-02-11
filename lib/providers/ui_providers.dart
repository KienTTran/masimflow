import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoolProvider extends Notifier<bool> {
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
}

final yamlFileUpdatedProvider = NotifierProvider<BoolProvider, bool>(() {
  return BoolProvider();
});

final markerSelectedProvider = NotifierProvider<BoolProvider, bool>(() {
  return BoolProvider();
});

final updateUIProvider = NotifierProvider<BoolProvider, bool>(() {
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