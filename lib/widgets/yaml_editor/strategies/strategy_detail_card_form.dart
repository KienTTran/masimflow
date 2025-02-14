import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/strategy_parameters.dart';
import 'package:masimflow/models/therapy.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../models/strategies/strategy.dart';
import '../../../utils/form_validator.dart';
import '../../../utils/utils.dart';

enum StrategyDetailCardFormType{
  integer,
  double,
  string,
  integerArray,
  doubleArray,
  doubleMatrix,
  singleTherapy,
  multipleTherapy,
  multipleStrategy,
}

class StrategyDetailCardForm extends ConsumerStatefulWidget {
  final StrategyDetailCardFormType type;
  final String controllerKey;
  final Strategy strategy;
  bool editable = false;
  final double width;
  double? lower = -1.0;
  double? upper = -1.0;
  String? typeKey = '';
  Map<int,Therapy>? therapyMap;
  StrategyParameters? strategyParameters;

  StrategyDetailCardForm({
    required this.type,
    required this.controllerKey,
    required this.strategy,
    required this.editable,
    required this.width,
    this.typeKey,
    this.lower,
    this.upper,
    this.therapyMap,
    this.strategyParameters,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => StrategyDetailCardFormState();
}

class StrategyDetailCardFormState extends ConsumerState<StrategyDetailCardForm> {
  
  @override
  Widget build(BuildContext context) {
    switch(widget.type) {
      case StrategyDetailCardFormType.integer:
        return StrategyIntegerFormField(widget.controllerKey, lower: int.parse(widget.lower.toString()), upper: int.parse(widget.upper.toString()));
      case StrategyDetailCardFormType.double:
        return StrategyDoubleFormField(widget.controllerKey, lower: widget.lower!, upper: widget.upper!);
      case StrategyDetailCardFormType.string:
        return StrategyStringFormField(widget.controllerKey);
      case StrategyDetailCardFormType.integerArray:
        return StrategyIntegerArrayFormField(widget.controllerKey, lower: int.parse(widget.lower.toString()), upper: int.parse(widget.upper.toString()));
      case StrategyDetailCardFormType.doubleArray:
        return StrategyDoubleArrayFormField(widget.controllerKey, typeKey: widget.typeKey!, lower: widget.lower!, upper: widget.upper!);
      case StrategyDetailCardFormType.doubleMatrix:
        return StrategyDoubleMatrixFormField(widget.controllerKey, lower: widget.lower!, upper: widget.upper!);
      case StrategyDetailCardFormType.singleTherapy:
        return StrategySingleTherapyFormField(widget.therapyMap!, widget.controllerKey);
      case StrategyDetailCardFormType.multipleTherapy:
        return StrategyMultipleTherapyFormField(widget.therapyMap!, widget.controllerKey);
      case StrategyDetailCardFormType.multipleStrategy:
        return StrategyMultipleStrategyFormField(widget.strategyParameters!,widget.controllerKey);
    }
  }
  
  Widget StrategyIntegerFormField(String controllerKey, {int lower = -1, int upper = -1}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.strategy.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.strategy.controllers[controllerKeyWithID]!.text,
        controller: widget.strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.strategy.controllers[controllerKeyWithID]!.text = value!;
          widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateIntRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyIntegerArrayFormField(String controllerKey, {int lower = -1, int upper = -1}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.strategy.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.strategy.controllers[controllerKeyWithID]!.text,
        controller: widget.strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.strategy.controllers[controllerKeyWithID]!.text = value!;
          widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateIntArrayRange(context,value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyDoubleArrayFormField(String controllerKey, {String typeKey = '', double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.strategy.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.strategy.controllers[controllerKeyWithID]!.text,
        controller: widget.strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.strategy.controllers[controllerKeyWithID]!.text = value!;
          widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDoubleArrayRange(context, value,
              lower: lower, upper: upper,
              length: typeKey.isNotEmpty ? (widget.strategy.controllers[Utils.getFormKeyID(widget.strategy.id, typeKey)]!.text.split(',').length) : 0);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyDoubleFormField(String controllerKey, {double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.strategy.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.strategy.controllers[controllerKeyWithID]!.text,
        controller: widget.strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.strategy.controllers[controllerKeyWithID]!.text = value!;
          widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDoubleRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyStringFormField(String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(widget.strategy.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.strategy.controllers[controllerKeyWithID]!.text,
        controller: widget.strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.strategy.controllers[controllerKeyWithID]!.text = value!;
          widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateString(context, value);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategySingleTherapyFormField(Map<int,Therapy> therapyMap,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(widget.strategy.id, controllerKey);
    List<int> selectedTherapyIndex = [];
    List<Therapy> selectedTherapies = [];
    try{
      selectedTherapyIndex = widget.strategy.controllers[controllerKeyWithID]!.text
          .replaceAll('[', '').replaceAll(']', '')
          .split(',')
          .map((e) => int.parse(e))
          .toList();
    }
    catch(e){
      print('Error parsing therapy ids: $e');
    }
    for (var i = 0; i < selectedTherapyIndex.length; i++) {
      selectedTherapies.add(therapyMap[selectedTherapyIndex[i]]!);
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
              controller: widget.strategy.controllers[controllerKeyWithID],
              onSaved: (value) {
                widget.strategy.controllers[controllerKeyWithID]!.text = value!;
                widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
              },
              validator: (value) {
                return FormUtil.validateIntArrayRange(context, value, lower: 0, upper: therapyMap.length - 1);
              },
            ),
            ShadSelectFormField<String>(
              controller: controller,
              minWidth: 340,
              onChanged: (value){
                selectedTherapyIndex.clear();selectedTherapyIndex.add(therapyMap.entries.firstWhere((element) => element.value.name == value).key);
                selectedTherapies.clear();
                for (var i = 0; i < selectedTherapyIndex.length; i++) {
                  selectedTherapies.add(therapyMap[selectedTherapyIndex[i]]!);
                }
                widget.strategy.controllers[controllerKeyWithID]!.text = selectedTherapyIndex.toString();
                widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: selectedTherapyIndex.toString());
              },
              initialValue: selectedTherapies.map((therapy) => therapy.name).toList().first,
              allowDeselection: true,
              closeOnSelect: false,
              placeholder: Text('Select therapy'),
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
              selectedOptionBuilder: (context, value) {
                return Text(value);
              },

            ),
          ],
        ),
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyMultipleTherapyFormField(Map<int,Therapy> therapyMap,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(widget.strategy.id, controllerKey);
    List<int> selectedTherapyIndex = [];
    List<Therapy> selectedTherapies = [];
    try{
      selectedTherapyIndex = widget.strategy.controllers[controllerKeyWithID]!.text
          .replaceAll('[', '').replaceAll(']', '')
          .split(',')
          .map((e) => int.parse(e))
          .toList();
    }
    catch(e){
      print('Error parsing therapy ids: $e');
    }
    for (var i = 0; i < selectedTherapyIndex.length; i++) {
      selectedTherapies.add(therapyMap[selectedTherapyIndex[i]]!);
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
              controller: widget.strategy.controllers[controllerKeyWithID],
              onSaved: (value) {
                widget.strategy.controllers[controllerKeyWithID]!.text = value!;
                widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
              },
              validator: (value) {
                return FormUtil.validateIntArrayRange(context, value, lower: 0, upper: therapyMap.length - 1);
              },
            ),
            ShadSelect<String>.multiple(
              controller: controller,
              minWidth: 340,
              onChanged: (value){
                selectedTherapyIndex.clear();
                for (var i = 0; i < value.length; i++) {
                  selectedTherapyIndex.add(therapyMap.entries.firstWhere((element) => element.value.name == value[i]).key);
                }
                selectedTherapies.clear();
                for (var i = 0; i < selectedTherapyIndex.length; i++) {
                  selectedTherapies.add(therapyMap[selectedTherapyIndex[i]]!);
                }
                widget.strategy.controllers[controllerKeyWithID]!.text = selectedTherapyIndex.toString();
                widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: selectedTherapyIndex.toString());
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
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyMultipleStrategyFormField(StrategyParameters strategyParameter,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(widget.strategy.id, controllerKey);
    List<int> selectedStrategyIndex = [];
    List<Strategy> selectedStrategies = [];
    try{
      selectedStrategyIndex = widget.strategy.controllers[controllerKeyWithID]!.text
          .replaceAll('[', '').replaceAll(']', '')
          .split(',')
          .map((e) => int.parse(e))
          .toList();
    }
    catch(e){
      print('Error parsing strategy ids: $e');
    }
    for (var i = 0; i < selectedStrategyIndex.length; i++) {
      selectedStrategies.add(strategyParameter.strategyDb[selectedStrategyIndex[i]]!);
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
              initialValue: selectedStrategies.toString(),
              readOnly: true,
              controller: widget.strategy.controllers[controllerKeyWithID],
              onSaved: (value) {
                widget.strategy.controllers[controllerKeyWithID]!.text = value!;
                widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
              },
              validator: (value) {
                return FormUtil.validateIntArrayRange(context, value, lower: 0, upper: strategyParameter.strategyDb.length - 1);
              },
            ),
            ShadSelect<String>.multiple(
              controller: controller,
              minWidth: 340,
              onChanged: (value){
                selectedStrategyIndex.clear();
                for (var i = 0; i < value.length; i++) {
                  selectedStrategyIndex.add(strategyParameter.strategyDb.entries.firstWhere((element) => element.value.name == value[i]).key);
                }
                selectedStrategies.clear();
                for (var i = 0; i < selectedStrategyIndex.length; i++) {
                  selectedStrategies.add(strategyParameter.strategyDb[selectedStrategyIndex[i]]!);
                }
                widget.strategy.controllers[controllerKeyWithID]!.text = selectedStrategyIndex.toString();
                widget.strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: selectedStrategyIndex.toString());
              },
              initialValues: selectedStrategies.map((therapy) => therapy.name).toList(),
              allowDeselection: true,
              closeOnSelect: false,
              placeholder: const Text('Select strategies'),
              options: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
                  child: Text('Strategies',
                    style: ShadTheme.of(context).textTheme.muted.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ShadTheme.of(context).colorScheme.popoverForeground,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                ...strategyParameter.strategyDb.values.map((therapy){
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
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyDoubleMatrixFormField(String controllerKey, {double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.strategy.id, controllerKey);
    return widget.editable
        ? SizedBox(
      width: widget.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Utils.getControllerKeyLabel(controllerKey)),SizedBox(
            // width: 60,
            child: ShadInputFormField(
              id: controllerKeyWithID,
              initialValue: widget.strategy.controllers[controllerKeyWithID]!.text,
              controller: widget.strategy.controllers[controllerKeyWithID],
              onSaved: (value) {
                // doublesByLocations[locationIndex][valueIndex] = double.tryParse(value) ?? 0.0;
                // widget.strategy.controllers['$controllerKeyWithID-$locationIndex-$valueIndex']!.text = value;
                // widget.strategy.controllers['$controllerKeyWithID-$locationIndex-$valueIndex']!.value = TextEditingValue(text: value);
              },
              // validator: (value) {
              //   return FormUtil.validateDoubleRange(context, value, lower: lower, upper: upper);
              // },
            ),
          ),
        ],
      ),
    )
        : Text(
        '${Utils.getControllerKeyLabel(controllerKey)}: ${widget.strategy.controllers[controllerKeyWithID]!.text}');
  } 
}
