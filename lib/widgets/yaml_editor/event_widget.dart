import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/widgets/yaml_editor/event_detail_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/events/event.dart';
import '../../utils/utils.dart';

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
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  @override
  Widget build(BuildContext context) {
    return ShadCard(
      width: widget.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: widget.width,
              child:
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.event.name.toString().split('_').join(' '),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  _buildEventActionButtons(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ShadAccordion<Event>(
                children: [
                  ShadAccordionItem(
                    title: Text('Properties'),
                    value: widget.event,
                    separator: null,
                    child: EventDetailCard(
                      eventID: widget.event.id,
                      width: widget.width,
                        height: widget.height,
                      editable: false,
                      popBack: (){}
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ShadButton.outline(
          onPressed: () {
            if (ref.read(configYamlFileProvider.notifier).getMutYamlMap().isEmpty) {
              showShadDialog(
                  context: context,
                  builder: (context) {
                    return ShadDialog.alert(
                      title: Text('Error'),
                      description: Text('Please load a yaml file first'),
                      actions: [
                        ShadButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  }
              );
            }
            else {
              showShadSheet(
                  context: context,
                  side: ShadSheetSide.right,
                  builder: (context) {
                    return ShadSheet(
                      constraints: const BoxConstraints(maxWidth: 512),
                      // title: Text(widget.event.name.replaceAll('_', ' ')),
                      title: Text(widget.event.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Material(
                                  child:
                                    EventDetailCard(
                                        eventID: widget.event.id,
                                        width: 512,
                                        height: widget.height,
                                        editable: true,
                                        popBack: () => Navigator.of(context).pop())
                                  )
                            ]
                        ),
                      ),
                      // actions: [
                      // ],
                    );
                  }
              );
            }
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
