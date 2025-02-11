import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class YamlTree extends ConsumerStatefulWidget {
  final treeNode;

  const YamlTree({
    Key? key,
    required this.treeNode,
  }) : super(key: key);

  @override
  _YamlTreeState createState() => _YamlTreeState();
}

class _YamlTreeState extends ConsumerState<YamlTree> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
    );
  }
}