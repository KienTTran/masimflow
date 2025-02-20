import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../models/therapies/therapy.dart';
import '../../../providers/data_providers.dart';

class TherapyDetailCard extends ConsumerStatefulWidget {
  final String therapyID;
  final double width;
  final double height;
  final bool editable;
  final VoidCallback popBack;
  final bool isUpdate;

  const TherapyDetailCard({
    super.key,
    required this.therapyID,
    required this.width,
    required this.height,
    required this.popBack,
    this.editable = false,
    this.isUpdate = true,
  });

  @override
  ConsumerState<TherapyDetailCard> createState() => _TherapyDetailCardState();
}

/// This widget wraps the _builddefaultTherapyDetails function. It accepts an therapy and a flag [editable].
class _TherapyDetailCardState extends ConsumerState<TherapyDetailCard> {
  DateTime randomDate = DateTime.now();
  late Therapy defaultTherapyDetail;

  @override
  void initState() {
    super.initState();
    defaultTherapyDetail = ref.read(therapyTemplateMapProvider.notifier).get()[widget.therapyID]!;
  }

  @override
  Widget build(BuildContext context) {
    var updateUI = ref.watch(updateUIProvider);

    if(updateUI){
      setState(() {
        defaultTherapyDetail = ref.read(therapyTemplateMapProvider.notifier).get()[widget.therapyID]!;
        defaultTherapyDetail.formKey = GlobalKey<ShadFormState>();
      });
    }
    // print('TherapyDetailCard build: ${widget.therapyID}');
    return SizedBox(
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTherapyDetails(defaultTherapyDetail, editable: widget.editable),
            const SizedBox(height: 32),
            (widget.editable && widget.isUpdate) ? SizedBox(
              width: widget.width*0.85,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShadButton(
                      onPressed: () {
                        if(defaultTherapyDetail.formKey.currentState!.validate(focusOnInvalid: true)){
                        }
                        else{
                          return;
                        }
                        try{
                          defaultTherapyDetail.update();
                          ref.read(therapyTemplateMapProvider.notifier).setTherapy(defaultTherapyDetail.id, defaultTherapyDetail);
                          ref.read(configYamlFileProvider.notifier).updateYamlValueByKeyList(defaultTherapyDetail.getYamlKeyList(),
                              defaultTherapyDetail.toYamlMap());
                        }
                        catch(e){
                          print('Error updating therapy: $e');
                        }
                        if(defaultTherapyDetail.formKey.currentState!.saveAndValidate()){
                          widget.popBack();
                          ref.read(updateUIProvider.notifier).update();
                        }
                      },
                      child: Text('Save changes')
                  ),
                  ShadButton(
                      onPressed: () {
                        defaultTherapyDetail.formKey.currentState!.reset();
                        setState(() {
                          defaultTherapyDetail = ref.read(therapyTemplateMapProvider.notifier).get()[widget.therapyID]!;
                          defaultTherapyDetail.formKey = GlobalKey<ShadFormState>();
                          ref.read(updateUIProvider.notifier).update();
                          widget.popBack();
                        });
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

  /// The modified _builddefaultTherapyDetails function with the extra parameter [editable].
  Widget buildTherapyDetails(Therapy therapy, {bool editable = false}) {
    // Access the starting and ending dates from your provider (adjust as needed)
    var startingDate = ref.read(dateMapProvider.notifier).get()['starting_date'];
    var endingDate = ref.read(dateMapProvider.notifier).get()['ending_date'];

    startingDate ??= DateTime.now();
    endingDate ??= DateTime.now();

    therapy.formWidth = widget.width;
    therapy.formEditable = editable;

    return Column(
      children: [therapy],
    );
  }
}

