import 'dart:convert';
import 'dart:io';
import 'dart:html' as webFile;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/config.dart';
import 'package:masimflow/widgets/yaml_editor/event_widget.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:yaml/yaml.dart';
import "package:flutter/services.dart" as s;

import '../../models/drug.dart';
import '../../models/events/event.dart';
import '../../models/strategy_marker.dart';
import '../../models/strategy_parameters.dart';
import '../../models/therapy.dart';
import '../../providers/data_providers.dart';
import '../../providers/ui_providers.dart';
import '../../models/config_marker.dart';
import '../../utils/yaml_writer.dart';
import '../yaml_editor.dart';

class YamlEditorRightPanel extends ConsumerStatefulWidget {
  final width;

  const YamlEditorRightPanel({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  _YamlEditorRightPanelState createState() => _YamlEditorRightPanelState();
}

class _YamlEditorRightPanelState extends ConsumerState<YamlEditorRightPanel> {
  String currentTab = 'events';
  DateTime startingDate = DateTime.now();
  DateTime endingDate = DateTime.now();
  DateTime compareDate = DateTime.now();
  List<ConfigMarker> configMarkerList = [];
  List<StrategyMarker> strategyMarkerList = [];
  List<Event> eventList = [];
  Map<int, Drug> drugMap = {};
  Map<int,Therapy> therapyMap = {};
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
      print('Error parsing yaml data: $e');
    }
  }

  void parseDrugData(YamlMap yamlFile){
    drugMap.clear();

    if(yamlFile.isEmpty) {
      return;
    }

    try{
      drugMap = DrugParser.parseFromString(yamlFile['drug_parameters']['drug_db'].toString());
      ref.read(drugMapProvider.notifier).set(drugMap);
      // print(drugMap);
    }
    catch (e) {
      print('Error parsing yaml data: $e');
    }
  }

  void parseTherapyData(YamlMap yamlFile){
    therapyMap.clear();

    if(yamlFile.isEmpty) {
      return;
    }

    try{
      therapyMap = TherapyParser.parseFromString(yamlFile['therapy_parameters']['therapy_db'].toString());
      ref.read(therapyMapProvider.notifier).set(therapyMap);
      print(therapyMap);
    }
    catch (e) {
      print('Error parsing yaml data: $e');
    }
  }

  void parseStrategyData(YamlMap yamlFile){

    if(yamlFile.isEmpty) {
      return;
    }

    try {
      strategyParameters = StrategyParameters.fromYaml(yamlFile);
      // ref.read(strategyMapProvider.notifier).set(strategyMap);
      print(strategyParameters.toString());
    }
    catch (e) {
      print('Error parsing yaml data: $e');
    }
  }

  void parseYamlData(YamlMap yamlFile,double canvasWidth) {

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
          100,
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
          100,
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
          -100,
          false,
          false,
          false
      );

      configMarkerList.add(endingTimeMarker);
      configMarkerList.add(startingTimeMarker);
      configMarkerList.add(compareTimeMarker);

      configMarkerList.sort((markerA, markerB) => markerA.x.compareTo(markerB.x));
      ref.read(configMarkerListProvider.notifier).set(configMarkerList);

      // Initial strategy marker
      var initialStrategyMarker = StrategyMarker(
          startingDate,endingDate,startingDate,
          -1,
          10,
          -50,
          'Initial Strategy',
          false,
          false,
          false,
          strategyParameters,
          therapyMap,
          drugMap
      );
      strategyMarkerList.add(initialStrategyMarker);

      strategyMarkerList.sort((markerA, markerB) => markerA.x.compareTo(markerB.x));
      ref.read(strategyMarkerListProvider.notifier).set(strategyMarkerList);

    } catch (e) {
      print('Error parsing yaml data: $e');
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
      var centerPanelWidth = ref.read(panelWidthMapProvider.notifier).getValue('center');
      parseYamlData(yamlFile,centerPanelWidth * 0.8);
    }
    catch (e) {
      print('Error parsing yaml data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loadEventConfigData();
    });
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
            ShadResizablePanel(
                defaultSize: 0.1,
                maxSize: 0.1,
                minSize: 0.1,
                child:
                Wrap(
                  direction: Axis.horizontal,
                  // mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadButton(
                      onPressed: () async {
                        loadConfigTemplateData();
                      },
                      icon: const Icon(Icons.file_open_sharp),
                      child: const Flexible(child: Text('Load config template', overflow: TextOverflow.ellipsis,)),
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
                              ref.read(configYamlFileProvider.notifier).set(yamlRaw);
                              ref.read(configYamlFileProvider.notifier).setFileName(result.files.single.name);
                              var centerPanelWidth = ref.read(panelWidthMapProvider.notifier).getValue('center');
                              parseYamlData(yamlRaw,centerPanelWidth * 0.8);
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
                      child: const Flexible(child: Text('Upload YML file', overflow: TextOverflow.ellipsis,)),
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
                      child: const Flexible(child: Text('Download YML file', overflow: TextOverflow.ellipsis,)),
                    )
                  ],
                ),
            ),
            ShadResizablePanel(
                defaultSize: 0.9,
                maxSize: 0.9,
                child: ref.read(configMarkerListProvider.notifier).get().isEmpty ?
                SizedBox() :ShadTabs(
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
                              emptyWidget:  Container(),
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
                      ) : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Events'),
                      ),
                      child: Flexible(child: Text('Events', overflow: TextOverflow.ellipsis,))
                    ),
                    ShadTab(
                        value: 'setting',
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(),
                        ),
                        child: Text('Settings', overflow: TextOverflow.ellipsis,),
                    )
                  ],
                )
            ),
          ]
      );
  }
}