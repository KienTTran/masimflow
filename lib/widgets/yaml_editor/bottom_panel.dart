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
  var allMarkers = [];

  @override
  void initState() {
    super.initState();
    ref.read(panelWidthMapProvider.notifier).setValue('bottom',widget.width);
  }

  @override
  Widget build(BuildContext context) {
    final updateUI = ref.watch(updateUIProvider);
    var configMarkers = ref.watch(configMarkerListProvider);
    var eventMarkers = ref.watch(eventMarkerListProvider);

    allMarkers.clear();
    allMarkers.addAll(configMarkers);
    allMarkers.addAll(eventMarkers);
    for(Marker marker in allMarkers){
      marker.setStartingDate(marker.startingDate);
      marker.setEndingDate(marker.endingDate);
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

    if(updateUI){
      allMarkers.clear();
      configMarkers = ref.watch(configMarkerListProvider);
      eventMarkers = ref.watch(eventMarkerListProvider);
      allMarkers.addAll(configMarkers);
      allMarkers.addAll(eventMarkers);
      for(Marker marker in allMarkers){
        marker.setStartingDate(marker.startingDate);
        marker.setEndingDate(marker.endingDate);
        if(marker is ConfigMarker){
          marker.setDate(marker.config.date);
          marker.updateX();
        }
        if(marker is EventMarker){
          marker.setDates(marker.event.dates());
          marker.updateXs();
        }
        // if(marker is ConfigMarker){
        //   print('configMarker ${marker.id} ${marker.config.name} ${marker.x}');
        // }
        // if(marker is EventMarker){
        //   print('before sort eventMarker ${marker.event.id} ${marker.event.name} ${marker.event.controllers.keys} ${marker.event.dates} ${marker.x}');
        // }
      }
      allMarkers.sort((a, b) => a.getSmallestX().compareTo(b.getSmallestX()));
      allMarkers.asMap().forEach((index, marker) {
        marker.updateIndex(allMarkers.length,index);
      });
      // for(Marker marker in allMarkers){
      //   if(marker is EventMarker){
      //     print('after sort eventMarker ${marker.event.id} ${marker.event.name} ${marker.event.controllers.values} ${marker.x}');
      //   }
      // }
    }

    // for(Marker marker in allMarkers){
    //   // if(marker is ConfigMarker){
    //   //   for(final key in marker.config.controllers.keys){
    //   //     print('Config ${marker.config.id} ${marker.config.yamlKeyList} $key ${marker.config.controllers[key]!.text}');
    //   //   }
    //   // }
    //   if(marker is EventMarker){
    //     for(final key in marker.event.controllers.keys){
    //       print('Bottom Event ${marker.event.id} ${marker.event.name} $key ${marker.event.controllers[key]!.text}');
    //     }
    //   }
    // }

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

  Widget ConfigCard(ConfigMarker marker, {bool detail = false}){
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
                  id: marker.config.id,
                  controller: marker.config.controllers['date'],
                  initialValue: DateFormat('yyyy/MM/dd').format(marker.config.date),
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
                      uDate = marker.config.controllers['date']!.text.isEmpty
                          ? DateTime.now()
                          : DateFormat('yyyy/MM/dd').parse(marker.config.controllers['date']!.text);
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
                      marker.config.controllers['date']!.text = DateFormat('yyyy/MM/dd').format(marker.config.date);
                      return;
                    }
                    final startingDate = ref.read(dateMapProvider.notifier).getDate('starting_date');
                    final endingDate = ref.read(dateMapProvider.notifier).getDate('ending_date');
                    if(!FormUtil.checkValidDate(context, uDate, startingDate!, endingDate!, isStart: marker.isStart, isEnd: marker.isEnd)){
                      marker.config.controllers['date']!.text = DateFormat('yyyy/MM/dd').format(marker.config.date);
                      return;
                    }

                    if(formKey.currentState!.validate(focusOnInvalid: true)) {
                      formKey.currentState!.save();
                      marker.config.updateDate(uDate);
                      marker.config.updateValue(marker.config.controllers['date']!.text);
                      ref.read(configYamlFileProvider.notifier).updateYamlValueByKeyList(
                          marker.config.yamlKeyList,
                          DateFormat('yyyy/MM/dd').format(uDate));
                      if(marker.isStart){
                        marker.setStartingDate(uDate);
                        ref.read(dateMapProvider.notifier).setDate('starting_date', uDate);
                      }
                      if(marker.isEnd){
                        marker.setEndingDate(uDate);
                        ref.read(dateMapProvider.notifier).setDate('ending_date', uDate);
                      }
                      marker.setDate(uDate);
                      marker.updateX();
                      for(Marker m in allMarkers){
                        m.setStartingDate(marker.startingDate);
                        m.setEndingDate(marker.endingDate);
                        m.updateXs();
                      }
                      ref.read(updateUIProvider.notifier).update();
                    }
                  },
                ),
              ),
            ],
          ),
          Text(
            Utils.getCapitalizedWords(marker.config.name),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),),
        ],
      ),
    );
  }
}
