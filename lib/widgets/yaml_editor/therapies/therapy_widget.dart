import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:masimflow/widgets/yaml_editor/strategies/strategy_detail_card.dart';
import 'package:masimflow/widgets/yaml_editor/therapies/therapy_detail_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../models/strategies/strategy.dart';
import '../../../models/therapies/therapy.dart';
import '../../../utils/utils.dart';

class TherapyCard extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final Therapy therapy;

  const TherapyCard({
    Key? key,
    required this.width,
    required this.height,
    required this.therapy,
  }) : super(key: key);

  @override
  ConsumerState<TherapyCard> createState() => _TherapyCardState();
}

class _TherapyCardState extends ConsumerState<TherapyCard> {

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
            SizedBox(
              // width: widget.width,
              child:
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Utils.getCapitalizedWords('${widget.therapy.initialIndex} | ${widget.therapy.name}'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.visible,
                        ),
                        widget.therapy.isMAC ? const ShadBadge.outline(
                          child: Text('MAC'),
                        ) : SizedBox(),
                      ],
                    ),
                  ),
                  _buildStrategyActionButtons(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ShadAccordion<Therapy>(
                children: [
                  ShadAccordionItem(
                    title: const Text('Properties'),
                    value: widget.therapy,
                    separator: null,
                    child: TherapyDetailCard(
                        therapyID: widget.therapy.id,
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

  Widget _buildStrategyActionButtons() {
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
                      title: const Text('Error'),
                      description: const Text('Please load a yaml file first'),
                      actions: [
                        ShadButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
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
                  isDismissible: false,
                  builder: (context) {
                    return ShadSheet(
                      constraints: const BoxConstraints(maxWidth: 512),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Utils.getCapitalizedWords(widget.therapy.name),),
                        ],
                      ),
                      // title: Text(widget.therapy.id),
                      closeIcon: const SizedBox(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [ Material( child: TherapyDetailCard(
                                        therapyID: widget.therapy.id,
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
          icon: Icon(Icons.edit),
        ),
      ],
    );
  }
}
