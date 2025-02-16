import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/widgets/yaml_editor/events/event_detail_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../models/events/event.dart';
import '../../../providers/ui_providers.dart';
import '../../../utils/utils.dart';

class EventCard extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final Event event;

  const EventCard({
    Key? key,
    required this.width,
    required this.height,
    required this.event,
  }) : super(key: key);

  @override
  ConsumerState<EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  @override
  Widget build(BuildContext context) {
    var updateUI = ref.watch(updateUIProvider);

    if(updateUI){
      setState(() {});
    }
    return ShadCard(
      width: widget.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          ],
        ),
      ),
    );
  }
}
