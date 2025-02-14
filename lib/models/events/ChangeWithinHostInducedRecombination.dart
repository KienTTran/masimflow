import 'package:flutter/material.dart';
import 'package:masimflow/widgets/yaml_editor/events/event_detail_card_form.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import 'event.dart';

class ChangeWithinHostInducedRecombination extends Event {
  ChangeWithinHostInducedRecombination({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, controllers: controllers);

  @override
  ChangeWithinHostInducedRecombination copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    return ChangeWithinHostInducedRecombination(
      id: newID,
      name: name,
      controllers: newControllers,
    );
  }

  @override
  void update() {}

  factory ChangeWithinHostInducedRecombination.fromYaml(
      Map<dynamic, dynamic> yaml) {
    final String id = const Uuid().v4();
    final Map<String, TextEditingController> controllers = {};
    yaml['info'].forEach((key, value) {
      controllers[Utils.getFormKeyID(id, key)] =
          TextEditingController(text: value.toString());
    });

    return ChangeWithinHostInducedRecombination(
      id: id,
      name: yaml['name'],
      controllers: controllers,
    );
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'info': {
        'date': controllers[Utils.getFormKeyID(id, 'date')]!.text,
        'value': controllers[Utils.getFormKeyID(id, 'value')]!.text,
      }
    };
  }

  @override
  void addEntry() {}

  @override
  void deleteEntry() {}

  @override
  ChangeWithinHostInducedRecombinationState createState() => ChangeWithinHostInducedRecombinationState();
}

class ChangeWithinHostInducedRecombinationState extends EventState<ChangeWithinHostInducedRecombination> {
  @override
  Widget build(BuildContext context) {
    return ShadForm(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.eventForm.EventDateFormField('date'),
          const SizedBox(height: 12),
          widget.eventForm.EventBoolFormField('value','True will enable Within Host Induced Recombination')
        ],
      ),
    );
  }
}