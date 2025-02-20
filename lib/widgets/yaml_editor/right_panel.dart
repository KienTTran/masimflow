import 'dart:convert';
import 'dart:io';
import 'dart:html' as webFile;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/configs/config.dart';
import 'package:masimflow/widgets/yaml_editor/strategies/new_strategy_widget.dart';
import 'package:masimflow/widgets/yaml_editor/strategies/strategy_detail_card_form.dart';
import 'package:masimflow/widgets/yaml_editor/strategies/strategy_widget.dart';
import 'package:masimflow/widgets/yaml_editor/therapies/new_therapy_widget.dart';
import 'package:masimflow/widgets/yaml_editor/therapies/therapy_widget.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';
import "package:flutter/services.dart" as s;

import '../../models/drugs/drug.dart';
import '../../models/events/event.dart';
import '../../models/markers/event_marker.dart';
import '../../models/markers/strategy_marker.dart';
import '../../models/strategies/strategy.dart';
import '../../models/strategies/strategy_parameters.dart';
import '../../models/therapies/therapy.dart';
import '../../providers/data_providers.dart';
import '../../providers/ui_providers.dart';
import '../../models/markers/config_marker.dart';
import '../../utils/utils.dart';
import '../../utils/yaml_writer.dart';
import '../yaml_editor.dart';
import 'events/event_widget.dart';

class YamlEditorRightPanel extends ConsumerStatefulWidget {
  final width;

  const YamlEditorRightPanel({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  ConsumerState<YamlEditorRightPanel> createState() => _YamlEditorRightPanelState();
}

class _YamlEditorRightPanelState extends ConsumerState<YamlEditorRightPanel> {
  String currentTab = 'events';
  DateTime startingDate = DateTime.now();
  DateTime endingDate = DateTime.now();
  DateTime compareDate = DateTime.now();
  List<ConfigMarker> configMarkerList = [];
  List<StrategyMarker> strategyMarkerList = [];
  List<Event> eventList = [];
  Map<String,Drug> drugMap = {};
  Map<String,Therapy> therapyMap = {};
  StrategyParameters strategyParameters = StrategyParameters(
    strategyDb: {},
    initialStrategyId: 0,
    recurrentTherapyId: 0,
    massDrugAdministration: MassDrugAdministration(
      ageBracketProbIndividualPresentAtMDA: [],
      enable: false,
      mdaTherapyId: 0,
      meanProbIndividualPresentAtMDA: [],
      sdProbIndividualPresentAtMDA: [],
    ),
  );

  void parseEventData(String eventFilePath) async {
    eventList.clear();
    ref.read(eventTemplateMapProvider.notifier).clear();

    try {
      eventList = await EventParser.fromAssets(eventFilePath);
      eventList.forEach((event) {
        ref.read(eventTemplateMapProvider.notifier).setEvent(event.id, event);
      });
    }
    catch (e) {
      print('Error parsing Event yaml data: $e');
    }
  }

  void parseEventDataFromYaml(YamlMap yamlMap) {
    eventList.clear();
    ref.read(eventTemplateMapProvider.notifier).clear();

    try {
      eventList = EventParser.fromYamlMap(yamlMap);
      eventList.forEach((event) {
        ref.read(eventDisplayMapProvider.notifier).setEvent(event.id, event);
      });
    }
    catch (e) {
      print('Error parsing Event yaml data: $e');
    }
  }

  void parseDrugData(YamlMap yamlFile){
    drugMap.clear();

    if(yamlFile.isEmpty) {
      return;
    }

    try{
      drugMap = DrugParser.parseFromString(yamlFile['drug_parameters']['drug_db'].toString());
      drugMap.forEach((key, value) {
        drugMap[key]!.initialIndex = value.initialIndex;
      });
      ref.read(drugMapProvider.notifier).set(drugMap);
      // print(drugMap);
      ref.read(drugMapProvider.notifier).set(drugMap);
    }
    catch (e) {
      print('Error parsing Drug yaml data: $e');
    }
  }

  void parseTherapyData(YamlMap yamlFile){
    therapyMap.clear();
    if(yamlFile.isEmpty) {
      return;
    }

    try{
      therapyMap = TherapyParser.parseFromString(yamlFile['therapy_parameters']['therapy_db'].toString());
      therapyMap.forEach((key, value) {
        therapyMap[key]!.initialIndex = value.initialIndex;
        if(therapyMap[key]?.therapyIds != null){
          therapyMap[key]?.isMAC = true;
        }
      });
      ref.read(therapyTemplateMapProvider.notifier).set(therapyMap);
      // print(therapyMap);
    }
    catch (e) {
      print('Error parsing Therapy yaml data: $e');
    }
  }

  void parseStrategyData(YamlMap yamlFile){
    if(yamlFile.isEmpty) {
      return;
    }
    ref.read(strategyTemplateMapProvider.notifier).clear();

    try {
      strategyParameters = StrategyParameters.fromYaml(yamlFile);
      ref.read(strategyParametersProvider.notifier).set(strategyParameters);
      for(final strategyKey in strategyParameters.strategyDb.keys){
        strategyParameters.strategies.elementAt(strategyKey).initialIndex = strategyKey;
        ref.read(strategyTemplateMapProvider.notifier)
            .setStrategy(strategyParameters.strategies.elementAt(strategyKey).id,
            strategyParameters.strategies.elementAt(strategyKey));
      }
    }
    catch (e) {
      print('Error parsing Strategy yaml data: $e');
    }
  }

  void parseYamlData(YamlMap yamlFile) {

    if(yamlFile.isEmpty) {
      return;
    }

    configMarkerList.clear();
    strategyMarkerList.clear();

    try {
      var timeframe = yamlFile['simulation_timeframe'];
      DateFormat format = DateFormat('yyyy/MM/dd');
      startingDate = format.parse(timeframe['starting_date']);
      endingDate = format.parse(timeframe['ending_date']);
      compareDate = format.parse(timeframe['start_of_comparison_period']);

      parseDrugData(yamlFile);
      parseTherapyData(yamlFile);
      parseStrategyData(yamlFile);

      ref.read(dateMapProvider.notifier).set({
        'starting_date': startingDate,
        'ending_date': endingDate,
      });

      // Starting time marker
      StartingDateConfig startingDateConfig = StartingDateConfig.fromYaml(yamlFile);
      var startingTimeMarker = ConfigMarker(
          startingDate,endingDate,
          startingDateConfig,
          -1,
          10,
          25,
          true,
          false,
          false
      );
      // Ending time marker
      EndingDateConfig endingDateConfig = EndingDateConfig.fromYaml(yamlFile);
      var endingTimeMarker = ConfigMarker(
          startingDate,endingDate,
          endingDateConfig,
          -1,
          10,
          25,
          false,
          true,
          false
      );
      // Compare time marker
      StartComparisonDateConfig startComparisonDateConfig = StartComparisonDateConfig.fromYaml(yamlFile);
      var compareTimeMarker = ConfigMarker(
          startingDate,endingDate,
          startComparisonDateConfig,
          -1,
          10,
          25,
          false,
          false,
          false
      );

      configMarkerList.add(endingTimeMarker);
      configMarkerList.add(startingTimeMarker);
      configMarkerList.add(compareTimeMarker);
      ref.read(configMarkerListProvider.notifier).set(configMarkerList);

      // Initial strategy marker
      var initialStrategyMarker = StrategyMarker(
          strategyParameters,
          therapyMap,
          drugMap,
          [(-1,startingDate,0,'')],
          [('',startingDate,0)],
          strategyParameters.strategies[strategyParameters.initialStrategyId].name,
          startingDate,endingDate,
          -1,
          10,
          30,
          false,
          false,
          false
      );
      Strategy initialStrategy = strategyParameters.strategies[strategyParameters.initialStrategyId];
      ref.read(initialStrategyProvider.notifier).set(initialStrategy);
      strategyMarkerList.add(initialStrategyMarker);
      ref.read(strategyMarkerListProvider.notifier).set(strategyMarkerList);

    } catch (e) {
      print('Error parsing Config yaml data: $e');
    }
  }

  void loadEventConfigData() async {
    String eventPath      = 'config/events.yaml';
    if(kIsWeb){
      //read to yaml
      eventPath = 'config/events.yaml';
    }
    else {
      eventPath = 'assets/config/events.yaml';
    }
    parseEventData(eventPath);
  }

  void loadConfigTemplateData() async {
    String configPath      = 'config/config_template.yaml';
    if(kIsWeb){
      //read to yaml
      configPath = 'config/config_template.yaml';
    }
    else {
      configPath = 'assets/config/config_template.yaml';
    }
    try {
      var yamlRaw = await s.rootBundle.loadString(configPath);
      var yamlFile = loadYaml(yamlRaw);
      ref.read(configYamlFileProvider.notifier).set(yamlFile);
      ref.read(configYamlFileProvider.notifier).setFileName('config_template.yaml');
      parseYamlData(yamlFile);
    }
    catch (e) {
      print('Error parsing Config Template yaml data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    ref.read(panelWidthMapProvider.notifier).setValue('right',widget.width);
  }

  @override
  Widget build(BuildContext context) {
    var updateUI = ref.watch(updateUIProvider);

    if(updateUI){
      setState(() {});
    }

    return ShadResizablePanelGroup(
          axis: Axis.vertical,
          children: [
            // ShadResizablePanel(
            //     defaultSize: 0.1,
            //     maxSize: 0.1,
            //     minSize: 0.1,
            //     child:,
            // ),
            ShadResizablePanel(
                defaultSize: 0.9,
                maxSize: 0.9,
                child: Column(
                  children: [
                    Wrap(
                      direction: Axis.horizontal,
                      // mainAxisSize: MainAxisSize.max,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShadButton(
                          onPressed: () async {
                            setState(() {
                              resetAllData();
                              loadEventConfigData();
                              loadConfigTemplateData();
                              ref.read(updateUIProvider.notifier).update();
                            });
                          },
                          icon: const Icon(Icons.file_open_sharp),
                          child: const Flexible(child: Text('Load template', overflow: TextOverflow.ellipsis,)),
                        ),
                        SizedBox(width: 10),
                        ShadButton(
                          onPressed: () async {
                            // Select file based on web or mobile
                            try{
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['yml','yaml'],
                              );
                              if (result != null && result.files.isNotEmpty) {
                                var yamlRaw;
                                if(kIsWeb){
                                  //read to yaml
                                  yamlRaw = loadYaml(utf8.decode(result.files.first.bytes!));
                                }
                                else {
                                  File file = File(result.files.single.path!);
                                  print(file.path);
                                  yamlRaw = loadYaml(file.path);
                                }
                                setState(() {
                                  resetAllData();
                                  ref.read(configYamlFileProvider.notifier).set(yamlRaw);
                                  ref.read(configYamlFileProvider.notifier).setFileName(result.files.single.name);
                                  parseYamlData(yamlRaw);
                                  parseEventDataFromYaml(yamlRaw);
                                  loadEventConfigData();
                                  addEventMarkers();
                                  ref.read(updateUIProvider.notifier).update();
                                });
                              } else {
                                // User canceled the picker
                                ref.read(configYamlFileProvider.notifier).set(YamlMap.wrap({}));
                              }
                            } on PlatformException catch (e) {
                              print('Unsupported operation $e');
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          child: const Flexible(child: Text('Upload YML', overflow: TextOverflow.ellipsis,)),
                        ),
                        SizedBox(height: 10),
                        ShadButton(
                          onPressed: () async {
                            // Select file based on web or mobile
                            try{
                              if (kIsWeb) {
                                final writer = YamlWriter();
                                final mutYamlFile = ref.read(configYamlFileProvider.notifier).getMutYamlMap();

                                if(mutYamlFile.isEmpty){
                                  return;
                                }

                                String yamlTest = writer.write(mutYamlFile);

                                List<String> file_contents = [yamlTest];
                                var blob = webFile.Blob(file_contents, 'text/plain', 'native');

                                var anchorElement = webFile.AnchorElement(
                                  href: webFile.Url.createObjectUrlFromBlob(blob).toString(),
                                )..setAttribute("download", "download_yaml.yml")..click();
                              }
                            } on PlatformException catch (e) {
                              print('Unsupported operation $e');
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                          icon: const Icon(Icons.save_alt),
                          child: const Flexible(child: Text('Download YML', overflow: TextOverflow.ellipsis,)),
                        )
                      ],
                    ),ref.read(configMarkerListProvider.notifier).get().isEmpty ?
                    SizedBox() : ShadTabs(
                      value: currentTab,
                      tabs: [
                        ShadTab(
                          value: 'events',
                          onPressed: (){
                            setState(() {
                              currentTab = 'events';
                            });
                          },
                          content: eventList.isNotEmpty ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.7,
                              child: SearchableList(
                                  initialList: eventList,
                                  filter: (value){
                                    return eventList.where((element) => element.name.contains(value)).toList();
                                  },
                                  displaySearchIcon: false,
                                  emptyWidget:  Container(),
                                  inputDecoration: const InputDecoration(
                                    labelText: "Search Events",
                                    fillColor: Colors.white,
                                    suffixIcon: Icon(Icons.search),
                                  ),
                                  itemBuilder: (Event event){
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: EventCard(
                                          width: widget.width*0.8,
                                          height: MediaQuery.of(context).size.height*0.7,
                                          event: event),
                                    );
                                  }
                              ),
                            ),
                          ) : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Events'),
                          ),
                          child: const Flexible(child: Text('Events', overflow: TextOverflow.ellipsis,))
                        ),
                        ShadTab(
                            value: 'strategies',
                            onPressed: (){
                              setState(() {
                                currentTab = 'strategies';
                              });
                            },
                            content: ref.read(strategyParametersProvider.notifier).get().strategyDb.isNotEmpty ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Initial Strategy', style: TextStyle(fontSize: 16)),
                                  StrategyDetailCardForm(
                                      type: StrategyDetailCardFormType.initialStrategy,
                                      width: widget.width,
                                      editable: true,
                                      controllerKey: '',
                                      strategy: ref.read(initialStrategyProvider.notifier).get(),
                                    strategyParameters: ref.read(strategyParametersProvider.notifier).get(),
                                  ),
                                  const Divider(),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height*0.6,
                                    child: SearchableList(
                                        initialList: ref.read(strategyParametersProvider.notifier).get().strategies,
                                        filter: (value){
                                          return ref.read(strategyParametersProvider.notifier).get().strategies
                                              .where((element) => element.name.contains(value)).toList();
                                        },
                                        displaySearchIcon: false,
                                        emptyWidget:  Container(),
                                        inputDecoration: const InputDecoration(
                                          labelText: "Search Strategies",
                                          fillColor: Colors.white,
                                          suffixIcon: Icon(Icons.search),
                                        ),
                                        secondaryWidget: ShadButton.outline(
                                          onPressed: (){
                                            showShadSheet(
                                                context: context,
                                                side: ShadSheetSide.right,
                                                isDismissible: false,
                                                builder: (context) {
                                                  return ShadSheet(
                                                    constraints: const BoxConstraints(maxWidth: 512),
                                                    title: Text('New Strategy'),
                                                    // title: Text(widget.event.id),
                                                    closeIcon: SizedBox(),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(bottom: 20),
                                                      child: NewStrategyCard(
                                                        width: 512,
                                                        height: widget.width,
                                                      ),
                                                    ),
                                                    // actions: [
                                                    // ],
                                                  );
                                                }
                                            );
                                          },
                                          icon: const Icon(Icons.add),
                                          child: const Text('New Strategy'),
                                        ),
                                        itemBuilder: (Strategy strategy){
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 16),
                                            child: StrategyCard(
                                                width: widget.width*0.8,
                                                height: MediaQuery.of(context).size.height*0.7,
                                                strategy: strategy),
                                          );
                                        }
                                    ),
                                  ),
                                ],
                              ),
                            ) : const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Strategies'),
                            ),
                            child: const Flexible(child: Text('Strategies', overflow: TextOverflow.ellipsis,))
                        ),
                        ShadTab(
                            value: 'therapies',
                            onPressed: (){
                              setState(() {
                                currentTab = 'therapies';
                              });
                            },
                            content: ref.read(therapyTemplateMapProvider.notifier).get().isNotEmpty ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height*0.6,
                                    child: SearchableList(
                                        initialList: ref.read(therapyTemplateMapProvider.notifier).get().values.toList(),
                                        filter: (value){
                                          return ref.read(therapyTemplateMapProvider.notifier).get().values.toList()
                                              .where((element) => element.name.contains(value)).toList();
                                        },
                                        displaySearchIcon: false,
                                        emptyWidget:  Container(),
                                        inputDecoration: const InputDecoration(
                                          labelText: "Search Therapies",
                                          fillColor: Colors.white,
                                          suffixIcon: Icon(Icons.search),
                                        ),
                                        secondaryWidget: ShadButton.outline(
                                          onPressed: (){
                                            showShadSheet(
                                                context: context,
                                                side: ShadSheetSide.right,
                                                isDismissible: false,
                                                builder: (context) {
                                                  return ShadSheet(
                                                    constraints: const BoxConstraints(maxWidth: 512),
                                                    title: Text('New Therapy'),
                                                    // title: Text(widget.event.id),
                                                    closeIcon: SizedBox(),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(bottom: 20),
                                                      child: NewTherapyCard(
                                                        width: 512,
                                                        height: widget.width,
                                                      ),
                                                    ),
                                                    // actions: [
                                                    // ],
                                                  );
                                                }
                                            );
                                          },
                                          icon: const Icon(Icons.add),
                                          child: const Text('New Therapy'),
                                        ),
                                        itemBuilder: (Therapy therapy){
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 16),
                                            child: TherapyCard(
                                                width: widget.width*0.8,
                                                height: MediaQuery.of(context).size.height*0.7,
                                                therapy: therapy),
                                          );
                                        }
                                    ),
                                  ),
                                ],
                              ),
                            ) : const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Therapies'),
                            ),
                            child: const Flexible(child: Text('Therapies', overflow: TextOverflow.ellipsis,))
                        ),
                        const ShadTab(
                            value: 'setting',
                            content: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(),
                            ),
                            child: Text('Settings', overflow: TextOverflow.ellipsis,),
                        )
                      ],
                    ),
                  ],
                )
            ),
          ]
      );
  }

  void resetAllData() {
    ref.read(eventDisplayMapProvider.notifier).set({});
    ref.read(eventMarkerListProvider.notifier).set([]);
    ref.read(strategyMarkerListProvider.notifier).set([]);
    ref.read(configMarkerListProvider.notifier).set([]);
    ref.read(strategyParametersProvider.notifier).set(StrategyParameters(
      strategyDb: {},
      initialStrategyId: 0,
      recurrentTherapyId: 0,
      massDrugAdministration: MassDrugAdministration(
        ageBracketProbIndividualPresentAtMDA: [],
        enable: false,
        mdaTherapyId: 0,
        meanProbIndividualPresentAtMDA: [],
        sdProbIndividualPresentAtMDA: [],
      ),
    ));
    ref.read(drugMapProvider.notifier).set({});
    ref.read(therapyTemplateMapProvider.notifier).set({});
    ref.read(dateMapProvider.notifier).set({});
    ref.read(configYamlFileProvider.notifier).set(YamlMap.wrap({}));
    ref.read(configYamlFileProvider.notifier).setFileName('');
  }

  void addEventMarkers() {
    for (final event in ref
        .read(eventDisplayMapProvider.notifier)
        .get()
        .values) {
      EventMarker newEventMarker = EventMarker(
          event,
          startingDate,
          endingDate,
          -1,
          10,
          -500,
          false
      );
      newEventMarker.strategyMarker = Utils.getEventStrategyMarkers(ref, event);
      ref.read(eventMarkerListProvider.notifier).add(newEventMarker);
    }
  }
}