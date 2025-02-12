import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import 'event.dart';

class MDADetail {
  DateTime date;
  List<double> fractionPopulationTargeted;
  int daysToCompleteAllTreatments;

  MDADetail({
    required this.date,
    required this.fractionPopulationTargeted,
    required this.daysToCompleteAllTreatments,
  });

  @override
  String toString() {
    return 'MDADetail(date: $date, fractionPopulationTargeted: $fractionPopulationTargeted, daysToCompleteAllTreatments: $daysToCompleteAllTreatments)';
  }
}

class SingleRoundMDA extends Event {
  List<MDADetail> mdaDetails;

  SingleRoundMDA({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
    required this.mdaDetails,
  }) : super(id: id, name: name, controllers: controllers);

  @override
  SingleRoundMDA copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    final newDetails = mdaDetails.map((detail) => MDADetail(
      date: DateTime.fromMillisecondsSinceEpoch(detail.date.millisecondsSinceEpoch),
      fractionPopulationTargeted: List.from(detail.fractionPopulationTargeted),
      daysToCompleteAllTreatments: detail.daysToCompleteAllTreatments,
    )).toList();

    return SingleRoundMDA(
      id: newID,
      name: name,
      mdaDetails: newDetails,
      controllers: newControllers,
    );
  }

  @override
  void addEntry() {
    final newDate = DateTime.now();
    mdaDetails.add(MDADetail(date: newDate, fractionPopulationTargeted: [1.0], daysToCompleteAllTreatments: 14));
    final dateKey = Utils.getFormKeyID(id, 'date_${mdaDetails.length - 1}');
    controllers[dateKey] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'fraction_population_targeted_${mdaDetails.length - 1}')] = TextEditingController(text: '1.0');
    controllers[Utils.getFormKeyID(id, 'days_to_complete_all_treatments_${mdaDetails.length - 1}')] = TextEditingController(text: '14');
    update();
  }

  @override
  void deleteEntry() {
    if (mdaDetails.isNotEmpty) {
      mdaDetails.removeLast();
      final dateKey = Utils.getFormKeyID(id, 'date_${mdaDetails.length}');
      controllers.remove(dateKey);
      controllers.remove(Utils.getFormKeyID(id, 'fraction_population_targeted_${mdaDetails.length}'));
      controllers.remove(Utils.getFormKeyID(id, 'days_to_complete_all_treatments_${mdaDetails.length}'));
      update();
    }
  }

  @override
  void update() {
    for (int i = 0; i < mdaDetails.length; i++) {
      final dateKey = Utils.getFormKeyID(id, 'date_$i');
      final fractionKey = Utils.getFormKeyID(id, 'fraction_population_targeted_$i');
      final daysKey = Utils.getFormKeyID(id, 'days_to_complete_all_treatments_$i');

      mdaDetails[i].date = DateFormat('yyyy/MM/dd').parse(controllers[dateKey]!.text);
      mdaDetails[i].fractionPopulationTargeted = controllers[fractionKey]!.text.split(',').map((e) => double.parse(e)).toList();
      mdaDetails[i].daysToCompleteAllTreatments = int.parse(controllers[daysKey]!.text);
    }
  }

  factory SingleRoundMDA.fromYaml(Map<dynamic, dynamic> yaml) {
    final String fID = const Uuid().v4();
    final List infoList = yaml['info'] as List;
    final fDetails = infoList.map((entry) => MDADetail(
      date: DateFormat('yyyy/MM/dd').parse(entry['date'].toString()),
      fractionPopulationTargeted: (entry['fraction_population_targeted'] as List).map((e) => double.parse(e.toString())).toList(),
      daysToCompleteAllTreatments: int.parse(entry['days_to_complete_all_treatments'].toString()),
    )).toList();
    final Map<String, TextEditingController> fControllers = {};
    for (int i = 0; i < fDetails.length; i++) {
      fControllers[Utils.getFormKeyID(fID, 'date_$i')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(fDetails[i].date));
      fControllers[Utils.getFormKeyID(fID, 'fraction_population_targeted_$i')] = TextEditingController(text: fDetails[i].fractionPopulationTargeted.join(','));
      fControllers[Utils.getFormKeyID(fID, 'days_to_complete_all_treatments_$i')] = TextEditingController(text: fDetails[i].daysToCompleteAllTreatments.toString());
    }

    return SingleRoundMDA(
      id: fID,
      name: yaml['name'],
      mdaDetails: fDetails,
      controllers: fControllers,
    );
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'info': mdaDetails.map((detail) => {
        'date': DateFormat('yyyy/MM/dd').format(detail.date),
        'fraction_population_targeted': detail.fractionPopulationTargeted,
        'days_to_complete_all_treatments': detail.daysToCompleteAllTreatments,
      }).toList(),
    };
  }

  @override
  SingleRoundMDAState createState() => SingleRoundMDAState();
}

class SingleRoundMDAState extends EventState<SingleRoundMDA> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.eventForm.width * 0.85,
      child: ShadForm(
        key: widget.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < widget.mdaDetails.length; i++)
              ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: widget.eventForm.width * 0.9 * 0.75,
                      child: widget.eventForm.EventDateFormField('date_$i'),
                    ),
                    (widget.eventForm.editable && i != 0 && i == widget.dates().length - 1) ? SizedBox(
                      // width: widget.eventForm.width * 0.9 * 0.15,
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
                widget.eventForm.EventDoubleArrayFormField('fraction_population_targeted_$i'),
                widget.eventForm.EventIntFormField('days_to_complete_all_treatments_$i'),
              ],
            widget.eventForm.editable ? Column(
              children: [
                const Divider(),
                ShadButton(
                  onPressed: () {
                    setState(() {
                      widget.addEntry();
                    });
                  },
                  child: const Text('Add MDA Detail'),
                ),
              ],
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
