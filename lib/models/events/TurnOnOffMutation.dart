import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import '../../widgets/yaml_editor/event_detail_card_form.dart';
import 'event.dart';

/// Helper model for a single TurnOffMutation entry.
class TurnOnOrOffMutationEntry {
  DateTime date;

  TurnOnOrOffMutationEntry({required this.date});

  factory TurnOnOrOffMutationEntry.fromYaml(Map<dynamic, dynamic> yaml) {
    return TurnOnOrOffMutationEntry(
      date: DateFormat('yyyy/MM/dd').parse(yaml['date'].toString()),
    );
  }

  Map<String, dynamic> toYaml() {
    return {
      'date': DateFormat('yyyy/MM/dd').format(date),
    };
  }

  TurnOnOrOffMutationEntry copy() {
    return TurnOnOrOffMutationEntry(date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch));
  }

  @override
  String toString() => 'TurnOffMutationEntry(date: $date)';
}

/// Event representing one or more turn-off mutation entries.
class TurnOffMutation extends Event {
  List<TurnOnOrOffMutationEntry> entries;
  Map<String, TextEditingController> controllers;

  TurnOffMutation({
    required String id,
    required String name,
    required this.entries,
    required this.controllers,
  }) : super(id: id, name: name, controllers: controllers);

  @override
  TurnOffMutation copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    final newEntries = entries.map((entry) => entry.copy()).toList();

    return TurnOffMutation(
      id: newID,
      name: name,
      entries: newEntries,
      controllers: newControllers,
    );
  }

  @override
  void addEntry() {
    final newDate = DateTime.now();
    entries.add(TurnOnOrOffMutationEntry(date: newDate));
    final dateKey = Utils.getFormKeyID(id, 'date_${entries.length - 1}');
    controllers[dateKey] = TextEditingController(
        text: DateFormat('yyyy/MM/dd').format(newDate));
    update();
  }

  @override
  void deleteEntry() {
    if (entries.isNotEmpty) {
      entries.removeLast();
      final dateKey = Utils.getFormKeyID(id, 'date_${entries.length}');
      controllers.remove(dateKey);
      update();
    }
  }

  @override
  void update() {
    //update entry dates based on controllers
    for (int i = 0; i < entries.length; i++) {
      final dateKey = Utils.getFormKeyID(id, 'date_${i}');
      entries[i].date =
          DateFormat('yyyy/MM/dd').parse(controllers[dateKey]!.text);
    }
  }

  factory TurnOffMutation.fromYaml(Map<dynamic, dynamic> yaml) {
    final String fID = const Uuid().v4();
    final List infoList = yaml['info'] as List;
    final fEntries = infoList
        .map((entry) => TurnOnOrOffMutationEntry.fromYaml(entry))
        .toList();

    final Map<String, TextEditingController> fControllers = {};
    for (int i = 0; i < fEntries.length; i++) {
      final dateKey = Utils.getFormKeyID(fID, 'date_$i');
      fControllers[dateKey] = TextEditingController(
          text: DateFormat('yyyy/MM/dd').format(fEntries[i].date));
    }

    return TurnOffMutation(
      id: fID,
      name: yaml['name'],
      entries: fEntries,
      controllers: fControllers,
    );
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'info': entries.map((entry) => entry.toYaml()).toList(),
    };
  }

  @override
  TurnOffMutationState createState() => TurnOffMutationState();
}

class TurnOffMutationState extends EventWidgetRenderState<TurnOffMutation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ShadForm(
          key: widget.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.entries.length; i++)
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    SizedBox(
                      width: widget.eventForm.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: widget.eventForm.width*0.9*0.75,
                            child: widget.eventForm.EventDateFormFieldWithRemoval('date', dateID: i.toString()),
                          ),
                          SizedBox(
                            width: widget.eventForm.width*0.9*0.2,
                            child: (widget.eventForm.editable && i != 0 && i == widget.dates().length - 1) ? SizedBox(
                              // width: widget.width*0.9*0.25,
                              child: ShadButton.ghost(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    widget.deleteEntry();
                                  });
                                },
                              ),
                            ) : SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        widget.eventForm.editable ? Column(
          children: [
            const Divider(),
            ShadButton(
                onPressed: () {
                  setState(() {
                    widget.addEntry();
                  });
                },
                child: Text('Add date')
            ),
          ],
        ) : SizedBox(),
      ],
    );
  }
}

/// Event representing one or more turn-off mutation entries.
class TurnOnMutation extends Event {
  List<TurnOnOrOffMutationEntry> entries;
  Map<String, TextEditingController> controllers;

  TurnOnMutation({
    required String id,
    required String name,
    required this.entries,
    required this.controllers,
  }) : super(id: id, name: name, controllers: controllers);

  @override
  TurnOnMutationState createState() => TurnOnMutationState();

  @override
  TurnOnMutation copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    final newEntries = entries.map((entry) => entry.copy()).toList();

    return TurnOnMutation(
      id: newID,
      name: name,
      entries: newEntries,
      controllers: newControllers,
    );
  }

  @override
  void addEntry() {
    final newDate = DateTime.now();
    entries.add(TurnOnOrOffMutationEntry(date: newDate));
    final dateKey = Utils.getFormKeyID(id, 'date_${entries.length - 1}');
    controllers[dateKey] = TextEditingController(
        text: DateFormat('yyyy/MM/dd').format(newDate));
    update();
  }

  @override
  void deleteEntry() {
    if (entries.isNotEmpty) {
      entries.removeLast();
      final dateKey = Utils.getFormKeyID(id, 'date_${entries.length}');
      controllers.remove(dateKey);
      update();
    }
  }

  @override
  void update() {
    //update entry dates based on controllers
    for (int i = 0; i < entries.length; i++) {
      final dateKey = Utils.getFormKeyID(id, 'date_${i}');
      entries[i].date =
          DateFormat('yyyy/MM/dd').parse(controllers[dateKey]!.text);
    }
  }

  factory TurnOnMutation.fromYaml(Map<dynamic, dynamic> yaml) {
    final String fID = const Uuid().v4();
    final List infoList = yaml['info'] as List;
    final fEntries = infoList
        .map((entry) => TurnOnOrOffMutationEntry.fromYaml(entry))
        .toList();

    final Map<String, TextEditingController> fControllers = {};
    for (int i = 0; i < fEntries.length; i++) {
      final dateKey = Utils.getFormKeyID(fID, 'date_$i');
      fControllers[dateKey] = TextEditingController(
          text: DateFormat('yyyy/MM/dd').format(fEntries[i].date));
    }

    return TurnOnMutation(
      id: fID,
      name: yaml['name'],
      entries: fEntries,
      controllers: fControllers,
    );
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'info': entries.map((entry) => entry.toYaml()).toList(),
    };
  }
}

class TurnOnMutationState extends EventWidgetRenderState<TurnOnMutation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ShadForm(
          key: widget.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.entries.length; i++)
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    SizedBox(
                      width: widget.eventForm.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: widget.eventForm.width*0.9*0.75,
                            child: widget.eventForm.EventDateFormFieldWithRemoval('date', dateID: i.toString()),
                          ),
                          SizedBox(
                            width: widget.eventForm.width*0.9*0.2,
                            child: (widget.eventForm.editable && i != 0 && i == widget.dates().length - 1) ? SizedBox(
                              // width: widget.width*0.9*0.25,
                              child: ShadButton.ghost(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    widget.deleteEntry();
                                  });
                                },
                              ),
                            ) : SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        widget.eventForm.editable ? Column(
          children: [
            const Divider(),
            ShadButton(
                onPressed: () {
                  setState(() {
                    widget.addEntry();
                  });
                },
                child: Text('Add date')
            ),
          ],
        ) : SizedBox(),
      ],
    );
  }
}
