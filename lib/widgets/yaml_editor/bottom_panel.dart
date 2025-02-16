import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/utils/form_validator.dart';
import 'package:masimflow/utils/hover_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../models/markers/event_marker.dart';
import '../../models/markers/marker.dart';
import '../../models/markers/strategy_marker.dart';
import '../../providers/ui_providers.dart';
import '../../models/markers/config_marker.dart';
import '../../utils/scrollable_widget.dart';
import '../../utils/utils.dart';
import 'events/event_detail_card.dart';

class YamlEditorBottomPanel extends ConsumerStatefulWidget {
  final width;
  final height;

  const YamlEditorBottomPanel({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  ConsumerState<YamlEditorBottomPanel> createState() => _YamlEditorBottomPanelState();
}

class _YamlEditorBottomPanelState extends ConsumerState<YamlEditorBottomPanel> {
  final formKey = GlobalKey<ShadFormState>();
  bool isMarkerEditing = false;
  List<String> errorMarkerId = [];
  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();
    ref.read(panelWidthMapProvider.notifier).setValue('bottom',widget.width);
  }

  @override
  Widget build(BuildContext context) {
    final updateUI = ref.watch(updateUIProvider);
    List<ConfigMarker> configMarkers = ref.watch(configMarkerListProvider);
    List<EventMarker> eventMarkers = ref.watch(eventMarkerListProvider);
    List<StrategyMarker> strategyMarkers = ref.watch(strategyMarkerListProvider);
    DateTime? startingDate = ref.read(dateMapProvider.notifier).getDate('starting_date');
    DateTime? endingDate = ref.read(dateMapProvider.notifier).getDate('ending_date');

    allMarkers.clear();
    allMarkers.addAll(configMarkers);
    allMarkers.addAll(eventMarkers);
    if(strategyMarkers.isNotEmpty){
      StrategyMarker initialStrategyMarker = strategyMarkers.first;
      allMarkers.add(initialStrategyMarker);
    }
    for(Marker marker in allMarkers){
      marker.setStartingDate(startingDate!);
      marker.setEndingDate(endingDate!);
      if(marker is ConfigMarker){
        // print('configMarker date: ${marker.config.date}');
        marker.setDate(marker.config.date);
        marker.updateX();
      }
      if(marker is EventMarker){
        marker.setDates(marker.event.dates());
        marker.updateXs();
      }
    }
    allMarkers.sort((a, b) => a.getSmallestX().compareTo(b.getSmallestX()));
    allMarkers.asMap().forEach((index, marker) {
      marker.updateIndex(allMarkers.length,index);
    });

    if(updateUI){
      allMarkers.clear();
      configMarkers = ref.watch(configMarkerListProvider);
      eventMarkers = ref.watch(eventMarkerListProvider);
      allMarkers.addAll(configMarkers);
      allMarkers.addAll(eventMarkers);
      for(Marker marker in allMarkers){
        marker.setStartingDate(startingDate!);
        marker.setEndingDate(endingDate!);
        if(marker is ConfigMarker){
          marker.setDate(marker.config.date);
          marker.updateX();
        }
        if(marker is EventMarker){
          marker.setDates(marker.event.dates());
          marker.updateXs();
        }
      }
      allMarkers.sort((a, b) => a.getSmallestX().compareTo(b.getSmallestX()));
      allMarkers.asMap().forEach((index, marker) {
        marker.updateIndex(allMarkers.length,index);
      });
    }

    return SizedBox(
      width: widget.width,
      child: allMarkers.isEmpty
          ? const SizedBox()
          : ShadResizablePanelGroup(
          axis: Axis.horizontal,
          children: [
            ShadResizablePanel(
                defaultSize: 0.9,
                minSize: 0.9,
                maxSize: 0.9,
                child: CustomScrollbarWithSingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: ScrollController(),
                  child: ShadForm(
                    key: formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(Marker marker in allMarkers)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                            child: HoverBuilder(
                              builder: (isHovered){
                                if(isHovered){
                                  for (var element in allMarkers) {
                                    element.selected = false;
                                  }
                                  marker.selected = true;
                                }
                                else{
                                  marker.selected = false;
                                }
                                return Row(
                                  children: [
                                    if(marker is ConfigMarker)
                                      ConfigCard(marker),
                                    if(marker is EventMarker)
                                      EventCard(marker)
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                )
            ),
          ]
      )
    );
  }

  Widget EventCard(EventMarker marker){
    double cardWidth = widget.width*0.2;
    return ShadCard(
      width: cardWidth,
      height: 150,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: marker.color,
                      width: 20.0,
                    ),
                  ),
                ),
                child: Text(
                    // marker.event.dates().toString(),
                    Utils.getEarliestDateString(marker.event.dates()),
                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14),
                ),
              ),
              SizedBox(
                width: cardWidth*0.3,
                child: ShadButton.ghost(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showShadSheet(
                        context: context,
                        side: ShadSheetSide.right,
                        builder: (context) {
                          return ShadSheet(
                            constraints: const BoxConstraints(maxWidth: 512),
                            // title: Text(widget.event.name.replaceAll('_', ' ')),
                            title: Text(marker.event.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Material(
                                        child:
                                        EventDetailCard(
                                            eventID: marker.event.id,
                                            width: 512,
                                            height: widget.height,
                                            editable: true,
                                            isUpdate: true,
                                            popBack: () => Navigator.of(context).pop()
                                        )
                                    )
                                  ]
                              ),
                            ),
                            // actions: [
                            // ],
                          );
                        }
                    );
                  },
                ),
              ),
            ],
          ),
          Text(
            Utils.getCapitalizedWords(marker.event.name),
            // marker.event.dates().toString(),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14
            ),
          ),
        ],
      ),
    );
  }

  Widget ConfigCard(ConfigMarker configMarker, {bool detail = false}){
    double cardWidth = widget.width*0.2;
    return ShadCard(
      width: cardWidth,
      height: 150,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: cardWidth*0.6,
                child: ShadInputFormField(
                  id: configMarker.config.id,
                  controller: configMarker.config.controllers['date'],
                  initialValue: DateFormat('yyyy/MM/dd').format(configMarker.config.date),
                  validator: (value){
                    return FormUtil.validateDate(context,value);
                  },
                ),
              ),
              SizedBox(
                width: cardWidth*0.3,
                child: ShadButton.ghost(
                  icon: const Icon(Icons.save),
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    DateTime uDate = DateTime.now();
                    try{
                      uDate = configMarker.config.controllers['date']!.text.isEmpty
                          ? DateTime.now()
                          : DateFormat('yyyy/MM/dd').parse(configMarker.config.controllers['date']!.text);
                    }
                    catch(e){
                      showShadDialog(context: context, builder: (context){
                        return ShadDialog(
                          title: const Text('Invalid date format'),
                          child: const Text('Please enter a valid date in the format yyyy/MM/dd'),
                          actions: [
                            ShadButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      });
                      configMarker.config.controllers['date']!.text = DateFormat('yyyy/MM/dd').format(configMarker.config.date);
                      return;
                    }
                    final startingDate = ref.read(dateMapProvider.notifier).getDate('starting_date');
                    final endingDate = ref.read(dateMapProvider.notifier).getDate('ending_date');
                    if(!FormUtil.checkValidDate(context, uDate, startingDate!, endingDate!, isStart: configMarker.isStart, isEnd: configMarker.isEnd)){
                      configMarker.config.controllers['date']!.text = DateFormat('yyyy/MM/dd').format(configMarker.config.date);
                      return;
                    }

                    if(formKey.currentState!.validate(focusOnInvalid: true)) {
                      formKey.currentState!.save();
                      configMarker.config.updateDate(uDate);
                      configMarker.config.updateValue(configMarker.config.controllers['date']!.text);
                      ref.read(configYamlFileProvider.notifier).updateYamlValueByKeyList(
                          configMarker.config.yamlKeyList,
                          DateFormat('yyyy/MM/dd').format(uDate));
                      if(configMarker.isStart){
                        // print('starting_date $uDate');
                        configMarker.setStartingDate(uDate);
                        ref.read(dateMapProvider.notifier).setDate('starting_date', uDate);
                      }
                      if(configMarker.isEnd){
                        // print('ending_date $uDate');
                        configMarker.setEndingDate(uDate);
                        ref.read(dateMapProvider.notifier).setDate('ending_date', uDate);
                      }
                      configMarker.setStartingDate(startingDate);
                      configMarker.setEndingDate(endingDate);
                      configMarker.setDate(uDate);
                      configMarker.updateX();
                      for(ConfigMarker marker in ref.read(configMarkerListProvider.notifier).get()){
                        marker.setStartingDate(configMarker.startingDate);
                        marker.setEndingDate(configMarker.endingDate);
                        marker.setDate(marker.config.date);
                        marker.updateX();
                        ref.read(configMarkerListProvider.notifier).update(marker);
                      }
                      var eventMarkerList = ref.read(eventMarkerListProvider.notifier).get();
                      for(EventMarker m in eventMarkerList){
                        m.setStartingDate(configMarker.startingDate);
                        m.setEndingDate(configMarker.endingDate);
                        m.strategyMarker = Utils.getEventStrategyMarkers(ref,m.event);
                        m.updateXs();
                      }
                      ref.read(eventMarkerListProvider.notifier).set(eventMarkerList);
                      ref.read(updateUIProvider.notifier).update();
                    }
                  },
                ),
              ),
            ],
          ),
          Text(
            Utils.getCapitalizedWords(configMarker.config.name),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),),
        ],
      ),
    );
  }
}
