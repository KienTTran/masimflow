import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:masimflow/widgets/yaml_editor/strategies/strategy_detail_card_form.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../models/strategies/strategy.dart';
import '../../../providers/data_providers.dart';

class StrategyDetailCard extends ConsumerStatefulWidget {
  final String strategyID;
  final double width;
  final double height;
  final bool editable;
  final VoidCallback popBack;

  const StrategyDetailCard({
    super.key,
    required this.strategyID,
    required this.width,
    required this.height,
    required this.popBack,
    this.editable = false,
  });

  @override
  ConsumerState<StrategyDetailCard> createState() => _StrategyDetailCardState();
}

/// This widget wraps the _builddefaultStrategyDetails function. It accepts an strategy and a flag [editable].
class _StrategyDetailCardState extends ConsumerState<StrategyDetailCard> {
  DateTime randomDate = DateTime.now();
  late Strategy defaultStrategyDetail;

  @override
  void initState() {
    super.initState();
    defaultStrategyDetail = ref.read(strategyTemplateMapProvider.notifier).get()[widget.strategyID]!;
  }

  @override
  Widget build(BuildContext context) {
    var updateUI = ref.watch(updateUIProvider);

    if(updateUI){
      setState(() {
        defaultStrategyDetail = ref.read(strategyTemplateMapProvider.notifier).get()[widget.strategyID]!;
        defaultStrategyDetail.formKey = GlobalKey<ShadFormState>();
      });
    }
    // print('StrategyDetailCard build: ${widget.strategyID}');
    return SizedBox(
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildStrategyDetails(defaultStrategyDetail, editable: widget.editable),
            const SizedBox(height: 32),
            (widget.editable) ? SizedBox(
              width: widget.width*0.85,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShadButton(
                      onPressed: () {
                        if(defaultStrategyDetail.formKey.currentState!.validate(focusOnInvalid: true)){
                        }
                        else{
                          return;
                        }
                        try{
                          defaultStrategyDetail.update();
                          ref.read(strategyParametersProvider.notifier).get().strategyDb[defaultStrategyDetail.initialIndex] = defaultStrategyDetail;
                          ref.read(strategyTemplateMapProvider.notifier).setStrategy(defaultStrategyDetail.id, defaultStrategyDetail);
                          ref.read(configYamlFileProvider.notifier).updateYamlValueByKeyList(defaultStrategyDetail.getYamlKeyList(),
                              defaultStrategyDetail.toYamlMap());
                        }
                        catch(e){
                          print('Error updating strategy: $e');
                        }
                        if(defaultStrategyDetail.formKey.currentState!.saveAndValidate()){
                          widget.popBack();
                          ref.read(updateUIProvider.notifier).update();
                        }
                      },
                      child: Text('Save changes')
                  ),
                  ShadButton(
                      onPressed: () {
                        // if(formKey.currentState!.validate()){
                        //   widget.popBack();
                        // }
                        // else{
                        //   return;
                        // }
                        widget.popBack();
                      },
                      child: Text('Cancel')
                  ),
                ],
              ),
            ) : SizedBox(),
          ],
        ),
      ),
    );
  }

  /// The modified _builddefaultStrategyDetails function with the extra parameter [editable].
  Widget buildStrategyDetails(Strategy strategy, {bool editable = false}) {
    // Access the starting and ending dates from your provider (adjust as needed)
    var startingDate = ref.read(dateMapProvider.notifier).get()['starting_date'];
    var endingDate = ref.read(dateMapProvider.notifier).get()['ending_date'];

    startingDate ??= DateTime.now();
    endingDate ??= DateTime.now();

    strategy.formWidth = widget.width;
    strategy.formEditable = editable;

    return Column(
      children: [strategy],
    );
  }
}

