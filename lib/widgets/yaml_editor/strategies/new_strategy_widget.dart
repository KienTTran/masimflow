import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/strategies/strategy.dart';

class NewStrategyCard extends ConsumerStatefulWidget {
  final double width;
  final double height;

  const NewStrategyCard({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  ConsumerState<NewStrategyCard> createState() => _NewStrategyCardState();
}

class _NewStrategyCardState extends ConsumerState<NewStrategyCard> {
  @override
  Widget build(BuildContext context) {
    return Text('NewStrategyCard');
  }
  
}
