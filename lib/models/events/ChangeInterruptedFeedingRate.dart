import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import 'event.dart';

class ChangeInterruptedFeedingRateInfo {
  int location;
  DateTime date;
  double interruptedFeedingRate;

  ChangeInterruptedFeedingRateInfo({
    required this.location,
    required this.date,
    required this.interruptedFeedingRate,
  });

  @override
  String toString() {
    return 'ChangeInterruptedFeedingRateInfo(location: $location, date: $date, interruptedFeedingRate: $interruptedFeedingRate)';
  }
}

class ChangeInterruptedFeedingRate extends Event {
  List<ChangeInterruptedFeedingRateInfo> feedingRateInfo;

  ChangeInterruptedFeedingRate({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
    required this.feedingRateInfo,
  }) : super(id: id, name: name, controllers: controllers);

  @override
  ChangeInterruptedFeedingRate copy() {
    final (newID, newControllers) = Utils.getNewFormControllers(id, controllers);
    final newFeedingRateInfo = feedingRateInfo.map((info) => ChangeInterruptedFeedingRateInfo(
      location: info.location,
      date: DateTime.fromMillisecondsSinceEpoch(info.date.millisecondsSinceEpoch),
      interruptedFeedingRate: info.interruptedFeedingRate,
    )).toList();

    return ChangeInterruptedFeedingRate(
      id: newID,
      name: name,
      feedingRateInfo: newFeedingRateInfo,
      controllers: newControllers,
    );
  }

  @override
  void addEntry() {
    final newDate = DateTime.now();
    feedingRateInfo.add(ChangeInterruptedFeedingRateInfo(location: 0, date: newDate, interruptedFeedingRate: 0.5));
    final index = feedingRateInfo.length - 1;
    controllers[Utils.getFormKeyID(id, 'location_$index')] = TextEditingController(text: '0');
    controllers[Utils.getFormKeyID(id, 'date_$index')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(newDate));
    controllers[Utils.getFormKeyID(id, 'interrupted_feeding_rate_$index')] = TextEditingController(text: '0.5');
    update();
  }

  @override
  void deleteEntry() {
    if (feedingRateInfo.isNotEmpty) {
      final index = feedingRateInfo.length - 1;
      feedingRateInfo.removeLast();
      controllers.remove(Utils.getFormKeyID(id, 'location_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'date_$index'));
      controllers.remove(Utils.getFormKeyID(id, 'interrupted_feeding_rate_$index'));
      update();
    }
  }

  @override
  void update() {
    for (int i = 0; i < feedingRateInfo.length; i++) {
      feedingRateInfo[i].location = int.parse(controllers[Utils.getFormKeyID(id, 'location_$i')]!.text);
      feedingRateInfo[i].date = DateFormat('yyyy/MM/dd').parse(controllers[Utils.getFormKeyID(id, 'date_$i')]!.text);
      feedingRateInfo[i].interruptedFeedingRate = double.parse(controllers[Utils.getFormKeyID(id, 'interrupted_feeding_rate_$i')]!.text);
    }
  }

  factory ChangeInterruptedFeedingRate.fromYaml(Map<dynamic, dynamic> yaml) {
    final String fID = const Uuid().v4();
    final List infoList = yaml['info'] as List;
    final fFeedingRateInfo = infoList.map((entry) => ChangeInterruptedFeedingRateInfo(
      location: entry['location'],
      date: DateFormat('yyyy/MM/dd').parse(entry['date'].toString()),
      interruptedFeedingRate: entry['interrupted_feeding_rate'].toDouble(),
    )).toList();

    final Map<String, TextEditingController> fControllers = {};
    for (int i = 0; i < fFeedingRateInfo.length; i++) {
      fControllers[Utils.getFormKeyID(fID, 'location_$i')] = TextEditingController(text: fFeedingRateInfo[i].location.toString());
      fControllers[Utils.getFormKeyID(fID, 'date_$i')] = TextEditingController(text: DateFormat('yyyy/MM/dd').format(fFeedingRateInfo[i].date));
      fControllers[Utils.getFormKeyID(fID, 'interrupted_feeding_rate_$i')] = TextEditingController(text: fFeedingRateInfo[i].interruptedFeedingRate.toString());
    }

    return ChangeInterruptedFeedingRate(
      id: fID,
      name: yaml['name'],
      feedingRateInfo: fFeedingRateInfo,
      controllers: fControllers,
    );
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'info': feedingRateInfo.map((info) => {
        'location': info.location,
        'date': DateFormat('yyyy/MM/dd').format(info.date),
        'interrupted_feeding_rate': info.interruptedFeedingRate,
      }).toList(),
    };
  }

  @override
  ChangeInterruptedFeedingRateState createState() => ChangeInterruptedFeedingRateState();
}

class ChangeInterruptedFeedingRateState extends EventState<ChangeInterruptedFeedingRate> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.eventForm.width * 0.85,
      child: ShadForm(
        key: widget.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < widget.feedingRateInfo.length; i++)
              ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: widget.eventForm.width*0.9*0.75,
                      child: widget.eventForm.EventIntFormField('location_$i', widget.feedingRateInfo[i].location),
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
                      widget.eventForm.EventDoubleFormField('interrupted_feeding_rate_$i', widget.feedingRateInfo[i].interruptedFeedingRate),
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
                  child: const Text('Add Feeding Rate Info'),
                ),
              ],
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
