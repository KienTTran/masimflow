import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import '../../widgets/yaml_editor/events/event_detail_card_form.dart';
import 'event.dart';

class Plas2ParasiteIntroduction {
  int location;
  DateTime date;
  double fraction;

  Plas2ParasiteIntroduction({
    required this.location,
    required this.date,
    required this.fraction,
  });

  @override
  String toString() {
    return 'Plas2ParasiteIntroduction(location: $location, date: $date, fraction: $fraction)';
  }
}

class IntroducePlas2Parasites extends Event {
  List<Plas2ParasiteIntroduction> introductions;

  IntroducePlas2Parasites({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
    required this.introductions,
  }) : super(id: id, name: name, controllers: controllers);

  @override
  IntroducePlas2Parasites copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    final newIntroductions = introductions.map((intro) => Plas2ParasiteIntroduction(
      location: intro.location,
      date: DateTime.fromMillisecondsSinceEpoch(intro.date.millisecondsSinceEpoch),
      fraction: intro.fraction,
    )).toList();

    return IntroducePlas2Parasites(
      id: newID,
      name: name,
      introductions: newIntroductions,
      controllers: newControllers,
    );
  }

  @override
  void addEntry() {
    final newDate = DateTime.now();
    introductions.add(Plas2ParasiteIntroduction(location: 0, date: newDate, fraction: 0.01));
    final index = introductions.length - 1;
    controllers[Utils.getFormKeyID(id, 'location_$index')] = TextEditingController(text: '0');
    controllers[Utils.getFormKeyID(id, 'date_$index')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'fraction_$index')] = TextEditingController(text: '0.01');
    update();
  }

  @override
  void deleteEntry() {
    if (introductions.isNotEmpty) {
      introductions.removeLast();
      final index = introductions.length;
      controllers.remove(Utils.getFormKeyID(id, 'location_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'date_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'fraction_$index'));
      update();
    }
  }

  @override
  void update() {
    for (int i = 0; i < introductions.length; i++) {
      introductions[i].location = int.parse(controllers[Utils.getFormKeyID(id, 'location_$i')]!.text);
      introductions[i].date = DateFormat('yyyy/MM/dd').parse(controllers[Utils.getFormKeyID(id, 'date_$i')]!.text);
      introductions[i].fraction = double.parse(controllers[Utils.getFormKeyID(id, 'fraction_$i')]!.text);
    }
  }

  factory IntroducePlas2Parasites.fromYaml(Map<dynamic, dynamic> yaml) {
    final String fID = const Uuid().v4();
    final List infoList = yaml['info'] as List;
    final fIntroductions = infoList.map((entry) => Plas2ParasiteIntroduction(
      location: entry['location'],
      date: DateFormat('yyyy/MM/dd').parse(entry['date'].toString()),
      fraction: entry['fraction'].toDouble(),
    )).toList();

    final Map<String, TextEditingController> fControllers = {};
    for (int i = 0; i < fIntroductions.length; i++) {
      fControllers[Utils.getFormKeyID(fID, 'location_$i')] = TextEditingController(text: fIntroductions[i].location.toString());
      fControllers[Utils.getFormKeyID(fID, 'date_$i')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(fIntroductions[i].date));
      fControllers[Utils.getFormKeyID(fID, 'fraction_$i')] = TextEditingController(text: fIntroductions[i].fraction.toString());
    }

    return IntroducePlas2Parasites(
      id: fID,
      name: yaml['name'],
      introductions: fIntroductions,
      controllers: fControllers,
    );
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'info': introductions.map((intro) => {
        'location': intro.location,
        'date': DateFormat('yyyy/MM/dd').format(intro.date),
        'fraction': intro.fraction,
      }).toList(),
    };
  }

  @override
  IntroducePlas2ParasitesState createState() => IntroducePlas2ParasitesState();
}

class IntroducePlas2ParasitesState extends EventState<IntroducePlas2Parasites> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.formWidth * 0.85,
      child: ShadForm(
        key: widget.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < widget.introductions.length; i++)
              ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: widget.formWidth * 0.9 * 0.75,
                      // child: widget.eventForm.EventIntegerFormField('location_$i', lower: 0),
                      child: EventDetailCardForm(
                        type: EventDetailCardFormType.integer,
                        controllerKey: 'location_$i',
                        editable: widget.formEditable,
                        width: widget.formWidth * 0.9 * 0.75,
                        event: widget,
                        lower: 0.0,
                        upper: -1.0,
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
                // widget.eventForm.EventDateFormField('date_$i'),
                // widget.eventForm.EventDoubleFormField('fraction_$i', lower: 0.0, upper: 1.0),
                EventDetailCardForm(
                  type: EventDetailCardFormType.date,
                  controllerKey: 'date_$i',
                  editable: widget.formEditable,
                  width: widget.formWidth * 0.9 * 0.75,
                  event: widget,
                  dateID: '',
                ),
                EventDetailCardForm(
                  type: EventDetailCardFormType.double,
                  controllerKey: 'fraction_$i',
                  editable: widget.formEditable,
                  width: widget.formWidth * 0.9 * 0.75,
                  event: widget,
                  lower: 0.0,
                  upper: 1.0,
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
                  child: const Text('Add Introduction'),
                ),
              ],
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
