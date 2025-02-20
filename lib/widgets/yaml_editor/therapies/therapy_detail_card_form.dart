import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/therapies/therapy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../models/drugs/drug.dart';
import '../../../models/strategies/strategy.dart';
import '../../../providers/ui_providers.dart';
import '../../../utils/form_validator.dart';
import '../../../utils/utils.dart';

enum TherapyDetailCardFormType{
  integerArray,
  string,
  multipleDrug,
  multipleTherapy,
}

class TherapyDetailCardForm extends ConsumerStatefulWidget {
  final TherapyDetailCardFormType type;
  final String controllerKey;
  final Therapy therapy;
  bool editable = false;
  final double width;
  double? lower = -1.0;
  double? upper = -1.0;
  String? typeKey = '';
  Map<String,Drug>? drugMap;
  Map<String,Therapy>? therapyMap;
  VoidCallback? onSaved;

  TherapyDetailCardForm({
    required this.type,
    required this.controllerKey,
    required this.therapy,
    required this.editable,
    required this.width,
    this.typeKey,
    this.lower,
    this.upper,
    this.drugMap,
    this.therapyMap,
    this.onSaved,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TherapyDetailCardFormState();
}

class TherapyDetailCardFormState extends ConsumerState<TherapyDetailCardForm> {

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    switch(widget.type) {
      case TherapyDetailCardFormType.string:
        return TherapyStringFormField(widget.controllerKey);
      case TherapyDetailCardFormType.integerArray:
        return TherapyIntegerArrayFormField(widget.controllerKey, lower: int.parse(widget.lower.toString()), upper: int.parse(widget.upper.toString()));
      case TherapyDetailCardFormType.multipleDrug:
        return TherapyMultipleDrugFormField(widget.drugMap!,widget.controllerKey);
      case TherapyDetailCardFormType.multipleTherapy:
        return TherapyMultipleTherapyFormField(widget.therapyMap!,widget.controllerKey);
    }
  }
  
  Widget TherapyIntegerArrayFormField(String controllerKey, {int lower = -1, int upper = -1}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.therapy.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.therapy.controllers[controllerKeyWithID]!.text,
        controller: widget.therapy.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.therapy.controllers[controllerKeyWithID]!.text = value!;
          widget.therapy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateIntArrayRange(context,value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.therapy.controllers[controllerKeyWithID]!.text}');
  }

  Widget TherapyStringFormField(String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(widget.therapy.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.therapy.controllers[controllerKeyWithID]!.text,
        controller: widget.therapy.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.therapy.controllers[controllerKeyWithID]!.text = value!;
          widget.therapy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateString(context, value);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.therapy.controllers[controllerKeyWithID]!.text}');
  }

  Widget TherapyMultipleDrugFormField(Map<String,Drug> drugMap,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(widget.therapy.id, controllerKey);
    List<int> selectedDrugIndex = [];
    List<Drug> selectedDrugs = [];
    try{
      selectedDrugIndex = Utils.extractIntegerList(widget.therapy.controllers[controllerKeyWithID]!.text);
    }
    catch(e){
      print('Error parsing therapy ids: $e');
    }
    for (var i = 0; i < selectedDrugIndex.length; i++) {
      Drug drug = drugMap.values.firstWhere((element) => element.initialIndex == selectedDrugIndex[i]);
      selectedDrugs.add(drug);
    }
    ShadPopoverController controller = ShadPopoverController();
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 340),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadInputFormField(
              id: controllerKeyWithID,
              label: Text(Utils.getControllerKeyLabel(controllerKey)),
              initialValue: selectedDrugs.toString(),
              readOnly: true,
              controller: widget.therapy.controllers[controllerKeyWithID],
              onSubmitted: (value) {
                widget.therapy.controllers[controllerKeyWithID]!.text = value!;
                widget.therapy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
              },
              validator: (value) {
                return FormUtil.validateIntArrayRange(context, value, lower: 0, upper: drugMap.length - 1);
              },
            ),
            ShadSelect<String>.multiple(
              controller: controller,
              minWidth: 340,
              enabled: widget.editable,
              onChanged: (value){
                selectedDrugIndex.clear();
                for (var i = 0; i < value.length; i++) {
                  selectedDrugIndex.add(drugMap.values.firstWhere((element) => element.name == value[i]).initialIndex);
                }
                selectedDrugs.clear();
                for (var i = 0; i < selectedDrugIndex.length; i++) {
                  Drug drug = drugMap.values.firstWhere((element) => element.initialIndex == selectedDrugIndex[i]);
                  selectedDrugs.add(drug);
                }
                widget.therapy.controllers[controllerKeyWithID]!.text = selectedDrugIndex.toString();
                widget.therapy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: selectedDrugIndex.toString());
              },
              initialValues: selectedDrugs.map((therapy) => therapy.name).toList(),
              allowDeselection: true,
              closeOnSelect: false,
              placeholder: Text('Select therapies'),
              options: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
                  child: Text('Therapies',
                    style: ShadTheme.of(context).textTheme.muted.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ShadTheme.of(context).colorScheme.popoverForeground,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                ...drugMap.values.map((therapy){
                  return ShadOption(
                    value: therapy.name,
                    child: Text('${therapy.initialIndex}: ${therapy.name}'),
                  );
                }
                ),
              ],
              selectedOptionsBuilder: (context, values) {
                return Text(values.map((v) => v).join(', '));
              },
            ),
          ],
        ),
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.therapy.controllers[controllerKeyWithID]!.text}');
  }


  Widget TherapyMultipleTherapyFormField(Map<String,Therapy> therapyMap,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(widget.therapy.id, controllerKey);
    List<int> selectedTherapyIndex = [];
    List<Therapy> selectedTherapies = [];
    try{
      selectedTherapyIndex = Utils.extractIntegerList(widget.therapy.controllers[controllerKeyWithID]!.text);
    }
    catch(e){
      print('Error parsing therapy ids: $e');
    }
    for (var i = 0; i < selectedTherapyIndex.length; i++) {
      Therapy therapy = therapyMap.values.firstWhere((element) => element.initialIndex == selectedTherapyIndex[i]);
      selectedTherapies.add(therapy);
    }
    ShadPopoverController controller = ShadPopoverController();
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 340),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShadInputFormField(
              id: controllerKeyWithID,
              label: Text(Utils.getControllerKeyLabel(controllerKey)),
              initialValue: selectedTherapies.toString(),
              readOnly: true,
              controller: widget.therapy.controllers[controllerKeyWithID],
              onSubmitted: (value) {
                widget.therapy.controllers[controllerKeyWithID]!.text = value!;
                widget.therapy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
              },
              validator: (value) {
                return FormUtil.validateIntArrayRange(context, value, lower: 0, upper: therapyMap.length - 1);
              },
            ),
            ShadSelect<String>.multiple(
              controller: controller,
              minWidth: 340,
              enabled: widget.editable,
              onChanged: (value){
                selectedTherapyIndex.clear();
                for (var i = 0; i < value.length; i++) {
                  selectedTherapyIndex.add(therapyMap.values.firstWhere((element) => element.name == value[i]).initialIndex);
                }
                selectedTherapies.clear();
                for (var i = 0; i < selectedTherapyIndex.length; i++) {
                  Therapy therapy = therapyMap.values.firstWhere((element) => element.initialIndex == selectedTherapyIndex[i]);
                  selectedTherapies.add(therapy);
                }
                widget.therapy.controllers[controllerKeyWithID]!.text = selectedTherapyIndex.toString();
                widget.therapy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: selectedTherapyIndex.toString());
              },
              initialValues: selectedTherapies.map((therapy) => therapy.name).toList(),
              allowDeselection: true,
              closeOnSelect: false,
              placeholder: Text('Select therapies'),
              options: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
                  child: Text('Therapies',
                    style: ShadTheme.of(context).textTheme.muted.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ShadTheme.of(context).colorScheme.popoverForeground,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                ...therapyMap.values.map((therapy){
                  return ShadOption(
                    value: therapy.name,
                    child: Text('${therapy.initialIndex}: ${therapy.name}'),
                  );
                }
                ),
              ],
              selectedOptionsBuilder: (context, values) {
                return Text(values.map((v) => v).join(', '));
              },
            ),
          ],
        ),
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.therapy.controllers[controllerKeyWithID]!.text}');
  }
}
