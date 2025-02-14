import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import 'event.dart';

/// Event representing a change in mutation probability per locus
class ChangeMutationProbabilityPerLocus extends Event {
  ChangeMutationProbabilityPerLocus({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
  }) : super(id: id, name: name, controllers: controllers);

  @override
  ChangeMutationProbabilityPerLocus copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    return ChangeMutationProbabilityPerLocus(
      id: newID,
      name: name,
      controllers: newControllers,
    );
  }

  @override
  void update() {
    // Placeholder for future logic
  }

  factory ChangeMutationProbabilityPerLocus.fromYaml(Map<dynamic, dynamic> yaml) {
    final String id = const Uuid().v4();
    final Map<String, TextEditingController> controllers = {};

    yaml['info'].forEach((key, value) {
      controllers[Utils.getFormKeyID(id, key)] =
          TextEditingController(text: value.toString());
    });

    return ChangeMutationProbabilityPerLocus(
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
        'mutation_probability_per_locus': controllers[Utils.getFormKeyID(id, 'mutation_probability_per_locus')]!.text,
      }
    };
  }

  @override
  void addEntry() {
    final newKey = Utils.getFormKeyID(id, 'locus_${controllers.length}');
    controllers[newKey] = TextEditingController(text: '0.0'); // Default probability
    update();
  }

  @override
  void deleteEntry() {
    if (controllers.isNotEmpty) {
      final lastKey = controllers.keys.last;
      controllers.remove(lastKey);
      update();
    }
  }

  @override
  ChangeMutationProbabilityPerLocusState createState() => ChangeMutationProbabilityPerLocusState();
}


class ChangeMutationProbabilityPerLocusState extends EventState<ChangeMutationProbabilityPerLocus> {

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
          widget.eventForm.EventDoubleFormField('mutation_probability_per_locus', lower: 0.0, upper: 1.0),
        ],
      ),
    );
  }
}