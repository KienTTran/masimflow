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
import '../../utils/yaml_writer.dart';
import '../yaml_editor.dart';

class YamlEditorLeftPanel extends ConsumerStatefulWidget {
  final yamlFile;

  const YamlEditorLeftPanel({
    Key? key,
    required this.yamlFile,
  }) : super(key: key);

  @override
  _YamlEditorLeftPanelState createState() => _YamlEditorLeftPanelState();
}

class _YamlEditorLeftPanelState extends ConsumerState<YamlEditorLeftPanel> {

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}