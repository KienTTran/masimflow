import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import '../../widgets/yaml_editor/events/event_detail_card_form.dart';
import 'event.dart';

class PeriodicParasiteInfo {
  DateTime startDate;
  int duration;
  String genotypeAaSequence;
  int numberOfCases;

  PeriodicParasiteInfo({
    required this.startDate,
    required this.duration,
    required this.genotypeAaSequence,
    required this.numberOfCases,
  });

  @override
  String toString() {
    return 'PeriodicParasiteInfo(startDate: $startDate, duration: $duration, genotypeAaSequence: $genotypeAaSequence, numberOfCases: $numberOfCases)';
  }
}

class PeriodicParasiteIntroduction {
  int location;
  List<PeriodicParasiteInfo> parasiteInfo;

  PeriodicParasiteIntroduction({
    required this.location,
    required this.parasiteInfo,
  });

  @override
  String toString() {
    return 'PeriodicParasiteIntroduction(location: $location, parasiteInfo: $parasiteInfo)';
  }
}

class IntroduceParasitesPeriodically extends Event {
  List<PeriodicParasiteIntroduction> introductions;

  IntroduceParasitesPeriodically({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
    required this.introductions,
  }) : super(id: id, name: name, controllers: controllers);

  void addParasiteInfo(int locationIndex){
    final newDate = DateTime.now();
    final lastInfo = introductions[locationIndex].parasiteInfo.last;
    introductions[locationIndex].parasiteInfo.add(PeriodicParasiteInfo(
      startDate: DateTime.now(),
      duration: 10,
      genotypeAaSequence: introductions[locationIndex].parasiteInfo.last.genotypeAaSequence,
      numberOfCases: 1,
    ));
    final index = introductions[locationIndex].parasiteInfo.length - 1;
    controllers[Utils.getFormKeyID(id, 'start_date_${locationIndex}_$index')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'duration_${locationIndex}_$index')] = TextEditingController(text: '10');
    controllers[Utils.getFormKeyID(id, 'genotype_aa_sequence_${locationIndex}_$index')] = TextEditingController(text: lastInfo.genotypeAaSequence);
    controllers[Utils.getFormKeyID(id, 'number_of_cases_${locationIndex}_$index')] = TextEditingController(text: '1');
    update();
  }

  void deleteParasiteInfo(int locationIndex){
    if (introductions[locationIndex].parasiteInfo.isNotEmpty) {
      final index = introductions[locationIndex].parasiteInfo.length - 1;
      introductions[locationIndex].parasiteInfo.removeLast();
      controllers.remove(Utils.getFormKeyID(id, 'start_date_${locationIndex}_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'duration_${locationIndex}_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'genotype_aa_sequence_${locationIndex}_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'number_of_cases_${locationIndex}_$index'));
      update();
    }
  }

  @override
  IntroduceParasitesPeriodically copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    final newIntroductions = introductions.map((intro) => PeriodicParasiteIntroduction(
      location: intro.location,
      parasiteInfo: intro.parasiteInfo.map((info) => PeriodicParasiteInfo(
        startDate: DateTime.fromMillisecondsSinceEpoch(info.startDate.millisecondsSinceEpoch),
        duration: info.duration,
        genotypeAaSequence: info.genotypeAaSequence,
        numberOfCases: info.numberOfCases,
      )).toList(),
    )).toList();

    return IntroduceParasitesPeriodically(
      id: newID,
      name: name,
      introductions: newIntroductions,
      controllers: newControllers,
    );
  }

  @override
  void addEntry() {
    final newDate = DateTime.now();
    final lastInfo = introductions.last.parasiteInfo.last;
    introductions.add(PeriodicParasiteIntroduction(location: 0, parasiteInfo: [
      PeriodicParasiteInfo(startDate: newDate, duration: 10, genotypeAaSequence: lastInfo.genotypeAaSequence, numberOfCases: 1)
    ]));
    final index = introductions.length - 1;
    controllers[Utils.getFormKeyID(id, 'location_$index')] = TextEditingController(text: '0');
    controllers[Utils.getFormKeyID(id, 'start_date_${index}_0')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'duration_${index}_0')] = TextEditingController(text: '10');
    controllers[Utils.getFormKeyID(id, 'genotype_aa_sequence_${index}_0')] = TextEditingController(text: lastInfo.genotypeAaSequence);
    controllers[Utils.getFormKeyID(id, 'number_of_cases_${index}_0')] = TextEditingController(text: '1');
    update();
  }

  @override
  void deleteEntry() {
    if (introductions.isNotEmpty) {
      introductions.removeLast();
      final index = introductions.length;
      controllers.remove(Utils.getFormKeyID(id, 'location_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'start_date_${index}_0'));
      controllers.remove(Utils.getFormKeyID(id, 'duration_${index}_0'));
      controllers.remove(Utils.getFormKeyID(id, 'genotype_aa_sequence_${index}_0'));
      controllers.remove(Utils.getFormKeyID(id, 'number_of_cases_${index}_0'));
      update();
    }
  }

  @override
  void update() {
    for (int i = 0; i < introductions.length; i++) {
      introductions[i].location = int.parse(controllers[Utils.getFormKeyID(id, 'location_$i')]!.text);
      for (int j = 0; j < introductions[i].parasiteInfo.length; j++) {
        introductions[i].parasiteInfo[j].startDate = DateFormat('yyyy/MM/dd').parse(controllers[Utils.getFormKeyID(id, 'start_date_${i}_$j')]!.text);
        introductions[i].parasiteInfo[j].duration = int.parse(controllers[Utils.getFormKeyID(id, 'duration_${i}_$j')]!.text);
        introductions[i].parasiteInfo[j].genotypeAaSequence = controllers[Utils.getFormKeyID(id, 'genotype_aa_sequence_${i}_$j')]!.text;
        introductions[i].parasiteInfo[j].numberOfCases = int.parse(controllers[Utils.getFormKeyID(id, 'number_of_cases_${i}_$j')]!.text);
      }
    }
  }
  factory IntroduceParasitesPeriodically.fromYaml(Map<dynamic, dynamic> yaml) {
    final String fID = const Uuid().v4();
    final List infoList = yaml['info'] as List;
    final fIntroductions = infoList.map((entry) => PeriodicParasiteIntroduction(
      location: entry['location'],
      parasiteInfo: (entry['parasite_info'] as List).map((info) => PeriodicParasiteInfo(
        startDate: DateFormat('yyyy/MM/dd').parse(info['start_date'].toString()),
        duration: info['duration'],
        genotypeAaSequence: info['genotype_aa_sequence'],
        numberOfCases: info['number_of_cases'],
      )).toList(),
    )).toList();

    final Map<String, TextEditingController> fControllers = {};
    for (int i = 0; i < fIntroductions.length; i++) {
      fControllers[Utils.getFormKeyID(fID, 'location_$i')] = TextEditingController(text: fIntroductions[i].location.toString());
      for (int j = 0; j < fIntroductions[i].parasiteInfo.length; j++) {
        fControllers[Utils.getFormKeyID(fID, 'start_date_${i}_$j')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(fIntroductions[i].parasiteInfo[j].startDate));
        fControllers[Utils.getFormKeyID(fID, 'duration_${i}_$j')] = TextEditingController(text: fIntroductions[i].parasiteInfo[j].duration.toString());
        fControllers[Utils.getFormKeyID(fID, 'genotype_aa_sequence_${i}_$j')] = TextEditingController(text: fIntroductions[i].parasiteInfo[j].genotypeAaSequence);
        fControllers[Utils.getFormKeyID(fID, 'number_of_cases_${i}_$j')] = TextEditingController(text: fIntroductions[i].parasiteInfo[j].numberOfCases.toString());
      }
    }

    return IntroduceParasitesPeriodically(
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
        'parasite_info': intro.parasiteInfo.map((info) => {
          'start_date': DateFormat('yyyy/MM/dd').format(info.startDate),
          'duration': info.duration,
          'genotype_aa_sequence': info.genotypeAaSequence,
          'number_of_cases': info.numberOfCases,
        }).toList(),
      }).toList(),
    };
  }

  @override
  IntroduceParasitesPeriodicallyState createState() => IntroduceParasitesPeriodicallyState();
}

class IntroduceParasitesPeriodicallyState extends EventState<IntroduceParasitesPeriodically> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.formWidth * 0.85,
      child: ShadForm(
        key: widget.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    (widget.formEditable && (i > 0)) ? SizedBox(
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
                for (int j = 0; j < widget.introductions[i].parasiteInfo.length; j++)
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: widget.formWidth * 0.9 * 0.75,
                              // child: widget.eventForm.EventIntegerFormField('duration_${i}_$j', lower: 0),
                              child: EventDetailCardForm(
                                type: EventDetailCardFormType.integer,
                                controllerKey: 'duration_${i}_$j',
                                editable: widget.formEditable,
                                width: widget.formWidth * 0.9 * 0.75,
                                event: widget,
                                lower: 0.0,
                                upper: -1.0,
                              )
                            ),
                            (widget.formEditable && (j != 0) && (j == widget.introductions[i].parasiteInfo.length - 1)) ? SizedBox(
                                child: ShadButton.ghost(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      widget.deleteParasiteInfo(i);
                                      widget.update();
                                    });
                                  },
                                )
                            ) : SizedBox()
                          ],
                        ),Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // widget.eventForm.EventGenotypeFormField('genotype_aa_sequence_${i}_$j'),
                            // widget.eventForm.EventIntegerFormField('number_of_cases_${i}_$j', lower: 0),
                            // widget.eventForm.EventDateFormField('start_date_${i}_$j'),
                            EventDetailCardForm(
                              type: EventDetailCardFormType.genotype,
                              controllerKey: 'genotype_aa_sequence_${i}_$j',
                              editable: widget.formEditable,
                              width: widget.formWidth * 0.9 * 0.75,
                              event: widget,
                            ),
                            EventDetailCardForm(
                              type: EventDetailCardFormType.integer,
                              controllerKey: 'number_of_cases_${i}_$j',
                              editable: widget.formEditable,
                              width: widget.formWidth * 0.9 * 0.75,
                              event: widget,
                              lower: 0.0,
                              upper: -1.0,
                            ),
                            EventDetailCardForm(
                              type: EventDetailCardFormType.date,
                              controllerKey: 'start_date_${i}_$j',
                              editable: widget.formEditable,
                              width: widget.formWidth * 0.9 * 0.75,
                              event: widget,
                              dateID: '',
                            ),
                            (widget.formEditable  && (j == widget.introductions[i].parasiteInfo.length - 1)) ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ShadButton(
                                  onPressed: () {
                                    setState(() {
                                      widget.addParasiteInfo(i);
                                    });
                                  },
                                  child: const Text('Add ParasiteInfo'),
                                ),
                              ],
                            ) : const SizedBox(),
                          ],
                        ),
                      ]
                    ),
                  )
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
