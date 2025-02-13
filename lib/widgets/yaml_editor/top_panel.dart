import 'dart:convert';
import 'dart:io';
import 'dart:html' as webFile;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:yaml/yaml.dart';

import '../../providers/data_providers.dart';
import '../../providers/ui_providers.dart';
import '../../models/markers/config_marker.dart';
import '../../utils/yaml_writer.dart';
import '../yaml_editor.dart';

class YamlEditorTopPanel extends ConsumerStatefulWidget {
  final yamlFile;

  const YamlEditorTopPanel({
    Key? key,
    required this.yamlFile,
  }) : super(key: key);

  @override
  ConsumerState<YamlEditorTopPanel> createState() => _YamlEditorTopPanelState();
}

class _YamlEditorTopPanelState extends ConsumerState<YamlEditorTopPanel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}