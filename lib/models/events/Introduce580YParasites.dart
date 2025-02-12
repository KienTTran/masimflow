import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import 'event.dart';

class Introduce580YParasiteInfo {
  int location;
  DateTime date;
  double fraction;

  Introduce580YParasiteInfo({
    required this.location,
    required this.date,
    required this.fraction,
  });

  @override
  String toString() {
    return 'Introduce580YParasiteInfo(location: $location, date: $date, fraction: $fraction)';
  }
}

class Introduce580YParasites extends Event {
  List<Introduce580YParasiteInfo> parasiteInfo;

  Introduce580YParasites({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
    required this.parasiteInfo,
  }) : super(id: id, name: name, controllers: controllers);

  void addParasiteInfo(int locationIndex) {
    final newDate = DateTime.now();
    parasiteInfo.add(Introduce580YParasiteInfo(location: locationIndex, date: newDate, fraction: 0.01));
    final index = parasiteInfo.length - 1;
    controllers[Utils.getFormKeyID(id, 'location_$index')] = TextEditingController(text: locationIndex.toString());
    controllers[Utils.getFormKeyID(id, 'date_$index')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'fraction_$index')] = TextEditingController(text: '0.01');
    update();
  }

  void deleteParasiteInfo(int locationIndex) {
    final index = parasiteInfo.indexWhere((info) => info.location == locationIndex);
    if (index != -1) {
      parasiteInfo.removeAt(index);
      controllers.remove(Utils.getFormKeyID(id, 'location_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'date_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'fraction_$index'));
    }
  }

  @override
  Introduce580YParasites copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    final newParasiteInfo = parasiteInfo.map((info) => Introduce580YParasiteInfo(
      location: info.location,
      date: DateTime.fromMillisecondsSinceEpoch(info.date.millisecondsSinceEpoch),
      fraction: info.fraction,
    )).toList();

    return Introduce580YParasites(
      id: newID,
      name: name,
      parasiteInfo: newParasiteInfo,
      controllers: newControllers,
    );
  }

  @override
  void addEntry() {
    final newDate = DateTime.now();
    parasiteInfo.add(Introduce580YParasiteInfo(location: 0, date: newDate, fraction: 0.01));
    final index = parasiteInfo.length - 1;
    controllers[Utils.getFormKeyID(id, 'location_$index')] = TextEditingController(text: '0');
    controllers[Utils.getFormKeyID(id, 'date_$index')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'fraction_$index')] = TextEditingController(text: '0.01');
    update();
  }

  @override
  void deleteEntry() {
    if (parasiteInfo.isNotEmpty) {
      final index = parasiteInfo.length - 1;
      parasiteInfo.removeLast();
      controllers.remove(Utils.getFormKeyID(id, 'location_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'date_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'fraction_$index'));
      update();
    }
  }

  @override
  void update() {
    for (int i = 0; i < parasiteInfo.length; i++) {
      parasiteInfo[i].location = int.parse(controllers[Utils.getFormKeyID(id, 'location_$i')]!.text);
      parasiteInfo[i].date = DateFormat('yyyy/MM/dd').parse(controllers[Utils.getFormKeyID(id, 'date_$i')]!.text);
      parasiteInfo[i].fraction = double.parse(controllers[Utils.getFormKeyID(id, 'fraction_$i')]!.text);
    }
  }

  factory Introduce580YParasites.fromYaml(Map<dynamic, dynamic> yaml) {
    final String fID = const Uuid().v4();
    final List infoList = yaml['info'] as List;
    final fParasiteInfo = infoList.map((entry) => Introduce580YParasiteInfo(
      location: entry['location'],
      date: DateFormat('yyyy/MM/dd').parse(entry['date'].toString()),
      fraction: entry['fraction'].toDouble(),
    )).toList();

    final Map<String, TextEditingController> fControllers = {};
    for (int i = 0; i < fParasiteInfo.length; i++) {
      fControllers[Utils.getFormKeyID(fID, 'location_$i')] = TextEditingController(text: fParasiteInfo[i].location.toString());
      fControllers[Utils.getFormKeyID(fID, 'date_$i')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(fParasiteInfo[i].date));
      fControllers[Utils.getFormKeyID(fID, 'fraction_$i')] = TextEditingController(text: fParasiteInfo[i].fraction.toString());
    }

    return Introduce580YParasites(
      id: fID,
      name: yaml['name'],
      parasiteInfo: fParasiteInfo,
      controllers: fControllers,
    );
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'info': parasiteInfo.map((info) => {
        'location': info.location,
        'date': DateFormat('yyyy/MM/dd').format(info.date),
        'fraction': info.fraction,
      }).toList(),
    };
  }

  @override
  Introduce580YParasitesState createState() => Introduce580YParasitesState();
}

class Introduce580YParasitesState extends EventState<Introduce580YParasites> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.eventForm.width * 0.85,
      child: ShadForm(
        key: widget.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < widget.parasiteInfo.length; i++)
              ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: widget.eventForm.width*0.9*0.75,
                      child: widget.eventForm.EventIntFormField('location_$i'),
                    ),
                    SizedBox(
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
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.eventForm.EventDateFormField('date_$i'),
                      widget.eventForm.EventDoubleFormField('fraction_$i'),
                    ],
                  ),
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
                  child: const Text('Add Parasite Info'),
                ),
              ],
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
