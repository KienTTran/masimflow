import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:masimflow/widgets/yaml_editor/strategies/strategy_detail_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
  late List<Strategy> templateStrategies = [];
  late Strategy selectedTemplateStrategy;
  ShadPopoverController controller = ShadPopoverController();

  @override void initState() {
    super.initState();
    templateStrategies = ref.read(strategyParametersProvider.notifier).get().strategies;
    selectedTemplateStrategy = templateStrategies.first;
    selectedTemplateStrategy.formKey = GlobalKey<ShadFormState>();
  }

  @override
  Widget build(BuildContext context) {
    bool updateUI = ref.watch(updateUIProvider);

    if(updateUI){
      setState(() {
        templateStrategies = ref.read(strategyParametersProvider.notifier).get().strategies;
      });
    }

    return SizedBox(
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create a new strategy from current strategy', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ShadSelect<String>(
              controller: controller,
              placeholder: const Text('Select a strategy'),
              options: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
                  child: Text(
                    'Strategy',
                    style: ShadTheme.of(context).textTheme.muted.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ShadTheme.of(context).colorScheme.popoverForeground,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                ...templateStrategies
                    .map((strategy){
                  final strategyKeyIndex = templateStrategies
                      .indexWhere((element) => element.id == strategy.id);
                  return ShadOption(
                      value: strategy.name.toString(),
                      child: Text('$strategyKeyIndex: ${strategy.name} (${strategy.type.typeAsString})'));
                })
              ],
              initialValue: templateStrategies.first.name,
              onChanged: (value) {
                int valueIdx = templateStrategies.indexWhere((element) => element.name == value);
                String valueId = templateStrategies[valueIdx].id;
                selectedTemplateStrategy = templateStrategies
                    .firstWhere((element) => element.id == valueId);
                setState(() {
                  ref.read(updateUIProvider.notifier).update();
                });
              },
              selectedOptionBuilder: (context, value){
                return templateStrategies.map((strategy) {
                  final strategyKeyIndex = templateStrategies
                      .indexWhere((element) => element.id == strategy.id);
                  return ShadOption(
                      value: strategy.name.toString(),
                      child: Text('$strategyKeyIndex: ${strategy.name} (${strategy.type.typeAsString})'));})
                    .toList()
                    .firstWhere((option) => option.value == value);
            }),
            StrategyDetailCard(
                strategyID: selectedTemplateStrategy.id,
                width: widget.width,
                height: widget.height,
                editable: true,
                isUpdate: false,
                popBack: (){}
            ),
            SizedBox(
              width: widget.width,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShadButton(
                      onPressed: () {
                        if(selectedTemplateStrategy.formKey.currentState!.validate(focusOnInvalid: true)){
                          Strategy newStrategy = selectedTemplateStrategy.copy();
                          newStrategy.update();
                          int newStrategyIndex = ref.read(strategyParametersProvider.notifier).get().strategyDb.length;
                          newStrategy.initialIndex = newStrategyIndex;
                          ref.read(strategyParametersProvider.notifier).get().strategyDb[newStrategyIndex] = newStrategy;
                          ref.read(strategyTemplateMapProvider.notifier).setStrategy(newStrategy.id, newStrategy);
                          ref.read(configYamlFileProvider.notifier).updateYamlValueByKeyList(newStrategy.getYamlKeyList(),
                              newStrategy.toYamlMap());
                          setState(() {
                            ref.read(updateUIProvider.notifier).update();
                            Navigator.of(context).pop();
                          });
                        }
                        else{
                          return;
                        }
                      },
                      child: Text('Add')
                  ),
                  ShadButton(
                      onPressed: () {
                        selectedTemplateStrategy.formKey.currentState!.reset();
                        setState(() {
                          selectedTemplateStrategy = ref.read(strategyTemplateMapProvider.notifier).get()[selectedTemplateStrategy.id]!;
                          selectedTemplateStrategy.formKey = GlobalKey<ShadFormState>();
                          ref.read(updateUIProvider.notifier).update();
                          Navigator.of(context).pop();
                        });
                      },
                      child: Text('Cancel')
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  
}
