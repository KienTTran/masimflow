
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingWidgetRender extends ConsumerStatefulWidget {
  // Constructor
  SettingWidgetRender({Key? key}) : super(key: key);

  @override
  SettingWidgetRenderState createState() => SettingWidgetRenderState();

}

class SettingWidgetRenderState<T extends SettingWidgetRender> extends ConsumerState<T> {
  // Override build
  @override
  Widget build(BuildContext context) {
    return Text('SettingWidgetRender');
  }
}

abstract class SettingState<T extends Setting> extends SettingWidgetRenderState<T> {
  @override
  Widget build(BuildContext context); // Force subclasses to implement build
}

abstract class Setting extends SettingWidgetRender {
  final String id;
  final String name;
  final Map<String, TextEditingController> controllers;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late double formWidth;
  bool formEditable = false;

  Setting({
    required this.id,
    required this.name,
    required this.controllers
  }) : super(key: Key(id));

  Map<String, dynamic> toYamlMap();

  Setting copy();
  void update();
  List<String> getYamlKeyList();

  List<DateTime> dates() {
    List<DateTime> dates = [];
    for (var key in controllers.keys) {
      if (key.contains('date')) {
        dates.add(DateFormat('yyyy/MM/dd').parse(controllers[key]!.text));
      }
    }
    return dates;
  }
}