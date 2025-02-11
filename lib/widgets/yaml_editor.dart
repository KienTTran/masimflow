import 'dart:convert';
import 'dart:io';
import 'dart:html' as webFile;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:masimflow/widgets/yaml_editor/bottom_panel.dart';
import 'package:masimflow/widgets/yaml_editor/center_panel.dart';
import 'package:masimflow/widgets/yaml_editor/right_panel.dart';
import 'package:masimflow/widgets/yaml_editor/top_panel.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:yaml_magic/yaml_magic.dart';

final Map<int, Color> colorMapper = {
  0: Colors.white,
  1: Colors.blueGrey[50]!,
  2: Colors.blueGrey[100]!,
  3: Colors.blueGrey[200]!,
  4: Colors.blueGrey[300]!,
  5: Colors.blueGrey[400]!,
  6: Colors.blueGrey[500]!,
  7: Colors.blueGrey[600]!,
  8: Colors.blueGrey[700]!,
  9: Colors.blueGrey[800]!,
  10: Colors.blueGrey[900]!,
};

extension ColorUtil on Color {
  Color byLuminance() =>
      computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
}

class YamlEditorWidget extends ConsumerStatefulWidget {
  const YamlEditorWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<YamlEditorWidget> createState() => _YamlEditorWidgetState();
}

class _YamlEditorWidgetState extends ConsumerState<YamlEditorWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var yamlFile = ref.watch(configYamlFileProvider);
    return Padding(
      padding: EdgeInsets.all(16.0),
      child:
      ShadResizablePanelGroup(
          axis: Axis.horizontal,
          children: [
            ShadResizablePanel(
              defaultSize: 0.8,
              maxSize: 0.8,
              minSize: 0.5,
              child: ShadResizablePanelGroup(
                axis: Axis.vertical,
                children: [
                  ShadResizablePanel(
                      defaultSize: 0.8,
                      minSize: 0.8,
                      maxSize: 0.8,
                      child: YamlEditorCenterPanel(
                          width: MediaQuery.of(context).size.width * 0.8,
                      )
                  ),
                  ShadResizablePanel(
                      defaultSize: 0.2,
                      maxSize: 0.2,
                      minSize: 0.2,
                      child: YamlEditorBottomPanel(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.2,
                      )
                  ),
                ],
              ),
            ),
            ShadResizablePanel(
                defaultSize: 0.2,
                minSize: 0.2,
                maxSize: 0.5,
                child: YamlEditorRightPanel(
                    width: MediaQuery.of(context).size.width * 0.2)
            ),
          ]
      )
    );
  }
}
