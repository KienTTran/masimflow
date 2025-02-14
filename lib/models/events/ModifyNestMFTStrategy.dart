import 'package:flutter/material.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import '../../widgets/yaml_editor/events/event_detail_card_form.dart';
import 'event.dart';

class NestedMFTStrategyChange {
  DateTime date;
  int strategyId;

  NestedMFTStrategyChange({
    required this.date,
    required this.strategyId,
  });

  @override
  String toString() {
    return 'NestedMFTStrategyChange(date: $date, strategyId: $strategyId)';
  }
}

class ModifyNestedMFTStrategy extends Event {
  List<NestedMFTStrategyChange> changes;

  ModifyNestedMFTStrategy({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
    required this.changes,
  }) : super(id: id, name: name, controllers: controllers);

  @override
  ModifyNestedMFTStrategy copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    final newChanges = changes.map((change) => NestedMFTStrategyChange(
      date: DateTime.fromMillisecondsSinceEpoch(change.date.millisecondsSinceEpoch),
      strategyId: change.strategyId,
    )).toList();

    return ModifyNestedMFTStrategy(
      id: newID,
      name: name,
      changes: newChanges,
      controllers: newControllers,
    );
  }

  @override
  void addEntry() {
    final newDate = DateTime.now();
    changes.add(NestedMFTStrategyChange(date: newDate, strategyId: 0));
    final dateKey = Utils.getFormKeyID(id, 'date_${changes.length - 1}');
    controllers[dateKey] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'strategy_id_${changes.length - 1}')] = TextEditingController(text: '0');
    update();
  }

  @override
  void deleteEntry() {
    if (changes.isNotEmpty) {
      changes.removeLast();
      final dateKey = Utils.getFormKeyID(id, 'date_${changes.length}');
      final strategyKey = Utils.getFormKeyID(id, 'strategy_id_${changes.length}');
      controllers.remove(dateKey);
      controllers.remove(strategyKey);
      update();
    }
  }

  @override
  void update() {
    for (int i = 0; i < changes.length; i++) {
      final dateKey = Utils.getFormKeyID(id, 'date_$i');
      changes[i].date = DateFormat('yyyy/MM/dd').parse(controllers[dateKey]!.text);
      changes[i].strategyId = int.parse(controllers[Utils.getFormKeyID(id, 'strategy_id_$i')]!.text);
    }
  }

  factory ModifyNestedMFTStrategy.fromYaml(Map<dynamic, dynamic> yaml) {
    final String fID = const Uuid().v4();
    final List infoList = yaml['info'] as List;
    final fChanges = infoList.map((entry) => NestedMFTStrategyChange(
      date: DateFormat('yyyy/MM/dd').parse(entry['date'].toString()),
      strategyId: entry['strategy_id'],
    )).toList();

    final Map<String, TextEditingController> fControllers = {};
    for (int i = 0; i < fChanges.length; i++) {
      final dateKey = Utils.getFormKeyID(fID, 'date_$i');
      fControllers[dateKey] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(fChanges[i].date));
      fControllers[Utils.getFormKeyID(fID, 'strategy_id_$i')] = TextEditingController(text: fChanges[i].strategyId.toString());
    }

    return ModifyNestedMFTStrategy(
      id: fID,
      name: yaml['name'],
      changes: fChanges,
      controllers: fControllers,
    );
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'info': changes.map((change) => {
        'date': DateFormat('yyyy/MM/dd').format(change.date),
        'strategy_id': change.strategyId,
      }).toList(),
    };
  }

  @override
  ModifyNestedMFTStrategyState createState() => ModifyNestedMFTStrategyState();
}

class ModifyNestedMFTStrategyState extends EventState<ModifyNestedMFTStrategy> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.formWidth * 0.85,
      child: ShadForm(
        key: widget.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < widget.changes.length; i++)
              ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: widget.formWidth * 0.9 * 0.75,
                      // child: widget.eventForm.EventDateFormField('date_$i'),
                      child: EventDetailCardForm(
                        type: EventDetailCardFormType.date,
                        controllerKey: 'date_$i',
                        editable: widget.formEditable,
                        width: widget.formWidth*0.9*0.75,
                        event: widget,
                        dateID: '',
                      ),
                    ),
                    (widget.formEditable && i != 0 && i == widget.dates().length - 1) ? SizedBox(
                      // width: widget.formWidth * 0.9 * 0.15,
                        child: ShadButton.ghost(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              widget.deleteEntry();
                              widget.update();
                            });
                          },
                        )
                    ) : SizedBox()
                  ],
                ),
                // widget.eventForm.EventSingleStrategyFormField(ref,
                //     ref.read(strategyParametersProvider.notifier).get(),
                //     'strategy_id_$i'),
                EventDetailCardForm(
                  type: EventDetailCardFormType.singleStrategy,
                  controllerKey: 'strategy_id_$i',
                  editable: widget.formEditable,
                  width: widget.formWidth * 0.9 * 0.75,
                  event: widget,
                  strategyParameters: ref.read(strategyParametersProvider.notifier).get(),
                ),
              ],
            widget.formEditable ? Column(
              children: [
                const Divider(),
                ShadButton(
                  onPressed: () {
                    setState(() {
                      widget.addEntry();
                    });
                  },
                  child: const Text('Add Strategy Modification'),
                ),
              ],
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
