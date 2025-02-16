import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/markers/strategy_marker.dart';
import 'package:masimflow/providers/data_providers.dart';

import '../../models/markers/event_marker.dart';
import '../../providers/ui_providers.dart';
import '../../models/markers/config_marker.dart';

class YamlEditorCenterPanel extends ConsumerStatefulWidget {
  final width;

  const YamlEditorCenterPanel({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  ConsumerState<YamlEditorCenterPanel> createState() => _YamlEditorCenterPanelState();
}

class _YamlEditorCenterPanelState extends ConsumerState<YamlEditorCenterPanel> {
  double lowerX = 0;
  double upperX = 0;
  double startingTimeX = 0.0;
  double endingTimeX = 0.0;
  double compareTimeX = 0.0;
  var mutYamlMap;
  double x = 0.0;
  double y = 0.0;

  @override
  void initState() {
    super.initState();
    lowerX = widget.width * 0.1;
    upperX = widget.width * 0.9;
    ref.read(panelWidthMapProvider.notifier).setValue('center',widget.width);
  }

  @override
  Widget build(BuildContext context) {
    lowerX = widget.width * 0.1;
    upperX = widget.width * 0.9;

    var mutYamlMap = ref.watch(configYamlFileProvider.notifier).getMutYamlMap();
    var configMarkerList = ref.watch(configMarkerListProvider);
    var strategyMarkerList = ref.watch(strategyMarkerListProvider);
    var eventMarkerList = ref.watch(eventMarkerListProvider);

    bool updateUI = ref.read(updateUIProvider.notifier).get();
    if(updateUI){
      setState(() {
        lowerX = widget.width * 0.1;
        upperX = widget.width * 0.9;
        eventMarkerList = ref.read(eventMarkerListProvider.notifier).get();
      });
    }

    if(configMarkerList.isEmpty){
      return Container();
    }

    if(mutYamlMap.isEmpty) {
      return Container();
    }

    return Container(
      width: widget.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.transparent,
      child: CustomPaint(
        painter: ShapePainter(
          ConfigMarkerList: configMarkerList,
          strategyMarkerList: strategyMarkerList,
          EventMarkerList: eventMarkerList,
          lowerX: lowerX,
          upperX: upperX,
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  List<ConfigMarker> ConfigMarkerList;
  List<StrategyMarker> strategyMarkerList;
  List<EventMarker> EventMarkerList;
  final double lowerX;
  final double upperX;

  ShapePainter({
    required this.ConfigMarkerList,
    required this.strategyMarkerList,
    required this.EventMarkerList,
    required this.lowerX,
    required this.upperX,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final ConfigMarkerLineY = size.height / 8;

    canvas.drawLine(
        Offset(lowerX,ConfigMarkerLineY),
        Offset(upperX,ConfigMarkerLineY),
        Paint()..color = Colors.black);
    // canvas.drawCircle(
    //     Offset(lowerX,ConfigMarkerLineY),
    //     10,
    //     Paint()..color = Colors.red);
    // canvas.drawCircle(
    //     Offset(upperX,ConfigMarkerLineY),
    //     10,
    //     Paint()..color = Colors.red);

    for(final marker in ConfigMarkerList) {
      marker.lowerX = lowerX;
      marker.upperX = upperX;
      marker.defaultY = ConfigMarkerLineY;
      marker.paint(canvas, size);
    }

    for(final marker in EventMarkerList) {
      marker.lowerX = lowerX;
      marker.upperX = upperX;
      marker.defaultY = ConfigMarkerLineY;
      marker.paint(canvas, size);
    }

    final strategyMarkerLineY = size.height * 0.65;

    canvas.drawLine(
        Offset(lowerX,strategyMarkerLineY),
        Offset(upperX,strategyMarkerLineY),
        Paint()..color = Colors.black);
    // canvas.drawCircle(
    //     Offset(lowerX,strategyMarkerLineY),
    //     10,
    //     Paint()..color = Colors.red);
    // canvas.drawCircle(
    //     Offset(upperX,strategyMarkerLineY),
    //     10,
    //     Paint()..color = Colors.red);
    canvas.drawRect(
        Rect.fromCenter(center: Offset(upperX,strategyMarkerLineY), width: 10, height: 10),
        Paint()..color = Colors.black);

    for(final marker in strategyMarkerList) {
      marker.lowerX = lowerX;
      marker.upperX = upperX;
      marker.defaultY = strategyMarkerLineY;
      marker.paint(canvas, size);
    }

    for(final marker in EventMarkerList) {
      if(marker.strategyMarker.strategyIdDateXLabelMapList.isNotEmpty){
        marker.strategyMarker.lowerX = lowerX;
        marker.strategyMarker.upperX = upperX;
        marker.strategyMarker.defaultY = ConfigMarkerLineY;
        marker.strategyMarker.paint(canvas, size);
      }
    }
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) => true;
}
