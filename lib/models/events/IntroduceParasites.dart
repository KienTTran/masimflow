import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import 'event.dart';

class ParasiteInfo {
  DateTime date;
  String genotypeAaSequence;
  int numberOfCases;

  ParasiteInfo({
    required this.date,
    required this.genotypeAaSequence,
    required this.numberOfCases,
  });

  @override
  String toString() {
    return 'ParasiteInfo(date: $date, genotypeAaSequence: $genotypeAaSequence, numberOfCases: $numberOfCases)';
  }
}

class ParasiteIntroduction {
  int location;
  List<ParasiteInfo> parasiteInfo;

  ParasiteIntroduction({
    required this.location,
    required this.parasiteInfo,
  });

  @override
  String toString() {
    return 'ParasiteIntroduction(location: $location, parasiteInfo: $parasiteInfo)';
  }
}

class IntroduceParasites extends Event {
  List<ParasiteIntroduction> introductions;

  IntroduceParasites({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
    required this.introductions,
  }) : super(id: id, name: name, controllers: controllers);

  @override
  IntroduceParasites copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    final newIntroductions = introductions.map((intro) => ParasiteIntroduction(
      location: intro.location,
      parasiteInfo: intro.parasiteInfo.map((info) => ParasiteInfo(
        date: DateTime.fromMillisecondsSinceEpoch(info.date.millisecondsSinceEpoch),
        genotypeAaSequence: info.genotypeAaSequence,
        numberOfCases: info.numberOfCases,
      )).toList(),
    )).toList();

    return IntroduceParasites(
      id: newID,
      name: name,
      introductions: newIntroductions,
      controllers: newControllers,
    );
  }
  
  void addParasiteInfo(int locationIndex) {
    final newDate = DateTime.now();
    final lastInfo = introductions[locationIndex].parasiteInfo.last;
    introductions[locationIndex].parasiteInfo.add(
      ParasiteInfo(
        date: newDate,
        genotypeAaSequence: lastInfo.genotypeAaSequence,
        numberOfCases: 1,
      ),
    );
    final infoIndex = introductions[locationIndex].parasiteInfo.length - 1;
    controllers[Utils.getFormKeyID(id, 'date_${locationIndex}_$infoIndex')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'genotype_aa_sequence_${locationIndex}_$infoIndex')] = TextEditingController(text: lastInfo.genotypeAaSequence);
    controllers[Utils.getFormKeyID(id, 'number_of_cases_${locationIndex}_$infoIndex')] = TextEditingController(text: '1');
    update();
  }

  void deleteParasiteInfo(int locationIndex) {
    if (introductions[locationIndex].parasiteInfo.isNotEmpty) {
      final infoIndex = introductions[locationIndex].parasiteInfo.length - 1;
      introductions[locationIndex].parasiteInfo.removeLast();
      controllers.remove(Utils.getFormKeyID(id, 'date_${locationIndex}_$infoIndex'));
      controllers.remove(Utils.getFormKeyID(id, 'genotype_aa_sequence_${locationIndex}_$infoIndex'));
      controllers.remove(Utils.getFormKeyID(id, 'number_of_cases_${locationIndex}_$infoIndex'));
      update();
    }
  }


  @override
  void addEntry() {
    final newDate = DateTime.now();
    introductions.add(ParasiteIntroduction(location: 0, parasiteInfo: [
      ParasiteInfo(date: newDate, genotypeAaSequence: introductions.last.parasiteInfo.last.genotypeAaSequence, numberOfCases: 1)
    ]));
    final index = introductions.length - 1;
    controllers[Utils.getFormKeyID(id, 'location_$index')] = TextEditingController(text: '0');
    controllers[Utils.getFormKeyID(id, 'date_${index}_0')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'genotype_aa_sequence_${index}_0')] = TextEditingController(text: introductions.last.parasiteInfo.last.genotypeAaSequence);
    controllers[Utils.getFormKeyID(id, 'number_of_cases_${index}_0')] = TextEditingController(text: '1');
    update();
  }

  @override
  void deleteEntry() {
    if (introductions.isNotEmpty) {
      introductions.removeLast();
      final index = introductions.length;
      controllers.remove(Utils.getFormKeyID(id, 'location_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'date_${index}_0'));
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
        introductions[i].parasiteInfo[j].date = DateFormat('yyyy/MM/dd').parse(controllers[Utils.getFormKeyID(id, 'date_${i}_$j')]!.text);
        introductions[i].parasiteInfo[j].genotypeAaSequence = controllers[Utils.getFormKeyID(id, 'genotype_aa_sequence_${i}_$j')]!.text;
        introductions[i].parasiteInfo[j].numberOfCases = int.parse(controllers[Utils.getFormKeyID(id, 'number_of_cases_${i}_$j')]!.text);
      }
    }
  }

  factory IntroduceParasites.fromYaml(Map<dynamic, dynamic> yaml) {
    final String fID = const Uuid().v4();
    final List infoList = yaml['info'] as List;
    final fIntroductions = infoList.map((entry) => ParasiteIntroduction(
      location: entry['location'],
      parasiteInfo: (entry['parasite_info'] as List).map((info) => ParasiteInfo(
        date: DateFormat('yyyy/MM/dd').parse(info['date'].toString()),
        genotypeAaSequence: info['genotype_aa_sequence'],
        numberOfCases: info['number_of_cases'],
      )).toList(),
    )).toList();

    final Map<String, TextEditingController> fControllers = {};
    for (int i = 0; i < fIntroductions.length; i++) {
      fControllers[Utils.getFormKeyID(fID, 'location_$i')] = TextEditingController(text: fIntroductions[i].location.toString());
      for (int j = 0; j < fIntroductions[i].parasiteInfo.length; j++) {
        fControllers[Utils.getFormKeyID(fID, 'date_${i}_$j')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(fIntroductions[i].parasiteInfo[j].date));
        fControllers[Utils.getFormKeyID(fID, 'genotype_aa_sequence_${i}_$j')] = TextEditingController(text: fIntroductions[i].parasiteInfo[j].genotypeAaSequence);
        fControllers[Utils.getFormKeyID(fID, 'number_of_cases_${i}_$j')] = TextEditingController(text: fIntroductions[i].parasiteInfo[j].numberOfCases.toString());
      }
    }

    return IntroduceParasites(
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
          'date': DateFormat('yyyy/MM/dd').format(info.date),
          'genotype_aa_sequence': info.genotypeAaSequence,
          'number_of_cases': info.numberOfCases,
        }).toList(),
      }).toList(),
    };
  }

  @override
  IntroduceParasitesState createState() => IntroduceParasitesState();
}

class IntroduceParasitesState extends EventState<IntroduceParasites> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.eventForm.width * 0.85,
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
                      width: widget.eventForm.width * 0.9 * 0.75,
                      child: widget.eventForm.EventIntegerFormField('location_$i', lower: 0),
                    ),
                    (widget.eventForm.editable && i != 0 && i == widget.introductions.length - 1) ? SizedBox(
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
                for (int j = 0; j < widget.introductions[i].parasiteInfo.length; j++)
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ...[
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: widget.eventForm.width * 0.9 * 0.75,
                                child: widget.eventForm.EventDateFormField('date_${i}_$j'),
                              ),
                              (widget.eventForm.editable && j != 0 && j == widget.introductions[i].parasiteInfo.length - 1) ? SizedBox(
                                // width: widget.eventForm.width * 0.9 * 0.15,
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
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.eventForm.EventIntegerFormField('number_of_cases_${i}_$j', lower: 0),
                              widget.eventForm.EventGenotypeFormField('genotype_aa_sequence_${i}_$j'),
                              (widget.eventForm.editable  && j == widget.introductions[i].parasiteInfo.length - 1 ) ? Column(
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
                      ],
                    )
                  )
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
