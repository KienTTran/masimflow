import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/event_marker.dart';
import 'package:masimflow/models/strategy_marker.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:yaml/yaml.dart';

import '../../providers/ui_providers.dart';
import '../../models/config_marker.dart';

class YamlEditorCenterPanel extends ConsumerStatefulWidget {
  final width;

  const YamlEditorCenterPanel({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  _YamlEditorCenterPanelState createState() => _YamlEditorCenterPanelState();
}

class _YamlEditorCenterPanelState extends ConsumerState<YamlEditorCenterPanel> {
  double lowerX = 0;
  double upperX = 0;
  double startingTimeX = 0.0;
  double endingTimeX = 0.0;
  double compareTimeX = 0.0;
  var mutYamlMap;

  bool isDown = false;
  double x = 0.0;
  double y = 0.0;

  // util function
  bool isInObject(ConfigMarker marker, double x, double y) {
    return (x - marker.x).abs() < 21 && (y - marker.y).abs() < 10;
  }
  // event handler
  void _down(DragStartDetails details, List<ConfigMarker> ConfigMarkerList) {
    setState(() {
      isDown = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;
    });
  }
  void _up() {
    setState(() {
      isDown = false;
    });
  }
  void _move(DragUpdateDetails details) {
    if (isDown) {
      setState(() {
        x += details.delta.dx;
        y += details.delta.dy;
        // print('x: $x, y: $y');
      });
    }
  }

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

    if(configMarkerList.isEmpty){
      return Container();
    }

    if(mutYamlMap.isEmpty) {
      return Container();
    }

    return GestureDetector(
      onPanStart: (details) {
        _down(details, configMarkerList);
      },
      onPanEnd: (details) {
        _up();
      },
      onPanUpdate: (details) {
        _move(details);
      },
      child: Container(
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

    final ConfigMarkerLineY = size.height / 4;

    canvas.drawLine(
        Offset(lowerX,ConfigMarkerLineY),
        Offset(upperX,ConfigMarkerLineY),
        Paint()..color = Colors.black);
    canvas.drawCircle(
        Offset(lowerX,ConfigMarkerLineY),
        10,
        Paint()..color = Colors.red);
    canvas.drawCircle(
        Offset(upperX,ConfigMarkerLineY),
        10,
        Paint()..color = Colors.red);

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

    final strategyMarkerLineY = size.height / 2;

    canvas.drawLine(
        Offset(lowerX,strategyMarkerLineY),
        Offset(upperX,strategyMarkerLineY),
        Paint()..color = Colors.black);

    for(final marker in strategyMarkerList) {
      marker.lowerX = lowerX;
      marker.upperX = upperX;
      marker.defaultY = strategyMarkerLineY;
      marker.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) => true;
}
