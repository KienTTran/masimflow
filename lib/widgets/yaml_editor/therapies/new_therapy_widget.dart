import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:masimflow/widgets/yaml_editor/strategies/strategy_detail_card.dart';
import 'package:masimflow/widgets/yaml_editor/therapies/therapy_detail_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../../models/strategies/strategy.dart';
import '../../../models/therapies/therapy.dart';
import '../../../utils/utils.dart';

class NewTherapyCard extends ConsumerStatefulWidget {
  final double width;
  final double height;

  const NewTherapyCard({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  ConsumerState<NewTherapyCard> createState() => _NewTherapyCardState();
}

class _NewTherapyCardState extends ConsumerState<NewTherapyCard> {
  late Therapy newTemplateTherapy;
  ShadPopoverController controller = ShadPopoverController();

  @override void initState() {
    super.initState();
    newTemplateTherapy = ref.read(therapyTemplateMapProvider.notifier).get().values.first.copy();
    newTemplateTherapy.name = 'New Therapy';
    newTemplateTherapy.controllers[Utils.getFormKeyID(newTemplateTherapy.id, 'name')] = TextEditingController(text: newTemplateTherapy.name);
    newTemplateTherapy.initialIndex = ref.read(therapyTemplateMapProvider.notifier).get().length;
    newTemplateTherapy.formKey = GlobalKey<ShadFormState>();
    newTemplateTherapy.formWidth = widget.width;
    newTemplateTherapy.formEditable = true;
  }

  @override
  Widget build(BuildContext context) {
    bool updateUI = ref.watch(updateUIProvider);

    if(updateUI){
      setState(() {});
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
            newTemplateTherapy,
            SizedBox(
              width: widget.width,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShadButton(
                      onPressed: () {
                        if(newTemplateTherapy.formKey.currentState!.validate(focusOnInvalid: true)){
                          newTemplateTherapy.update();
                          ref.read(therapyTemplateMapProvider.notifier).setTherapy(newTemplateTherapy.id, newTemplateTherapy);
                          ref.read(configYamlFileProvider.notifier).updateYamlValueByKeyList(newTemplateTherapy.getYamlKeyList(),
                              newTemplateTherapy.toYamlMap());
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
                        newTemplateTherapy.formKey.currentState!.reset();
                        setState(() {
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
