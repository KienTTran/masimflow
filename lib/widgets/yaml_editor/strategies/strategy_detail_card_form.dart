import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/models/strategy_parameters.dart';
import 'package:masimflow/models/therapy.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../utils/form_validator.dart';
import '../../../utils/utils.dart';

class StrategyDetailCardForm {
  BuildContext context;
  Strategy strategy;
  bool editable;
  double width;

  StrategyDetailCardForm(this.context, this.strategy, this.editable, this.width);

  Widget StrategyIntegerFormField(String controllerKey, {int lower = -1, int upper = -1}){
    String controllerKeyWithID = Utils.getFormKeyID(strategy.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: strategy.controllers[controllerKeyWithID]!.text,
        controller: strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          strategy.controllers[controllerKeyWithID]!.text = value!;
          strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateIntRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyIntegerArrayFormField(String controllerKey, {int lower = -1, int upper = -1}){
    String controllerKeyWithID = Utils.getFormKeyID(strategy.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: strategy.controllers[controllerKeyWithID]!.text,
        controller: strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          strategy.controllers[controllerKeyWithID]!.text = value!;
          strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateIntArrayRange(context,value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyDoubleArrayFormField(String controllerKey, {String typeKey = '', double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(strategy.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: strategy.controllers[controllerKeyWithID]!.text,
        controller: strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          strategy.controllers[controllerKeyWithID]!.text = value!;
          strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDoubleArrayRange(context, value,
          lower: lower, upper: upper,
          length: typeKey.isNotEmpty ? (strategy.controllers[Utils.getFormKeyID(strategy.id, typeKey)]!.text.split(',').length) : 0);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyDoubleFormField(String controllerKey, {double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(strategy.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: strategy.controllers[controllerKeyWithID]!.text,
        controller: strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          strategy.controllers[controllerKeyWithID]!.text = value!;
          strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDoubleRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyStringFormField(String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(strategy.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: strategy.controllers[controllerKeyWithID]!.text,
        controller: strategy.controllers[controllerKeyWithID],
        onSaved: (value) {
          strategy.controllers[controllerKeyWithID]!.text = value!;
          strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateString(context, value);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategySingleTherapyFormField(WidgetRef ref,Map<int,Therapy> therapyMap,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(strategy.id, controllerKey);
    List<int> selectedTherapyIndex = [];
    List<Therapy> selectedTherapies = [];
    try{
      selectedTherapyIndex = strategy.controllers[controllerKeyWithID]!.text
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
    return editable ? SizedBox(
      width: width*0.9,
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
              enabled: false,
              controller: strategy.controllers[controllerKeyWithID],
              onSaved: (value) {
                strategy.controllers[controllerKeyWithID]!.text = value!;
                strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
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
                strategy.controllers[controllerKeyWithID]!.text = selectedTherapyIndex.toString();
                strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: selectedTherapyIndex.toString());
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
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${strategy.controllers[controllerKeyWithID]!.text}');
  }


  Widget StrategyMultipleTherapyFormField(WidgetRef ref,Map<int,Therapy> therapyMap,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(strategy.id, controllerKey);
    List<int> selectedTherapyIndex = [];
    List<Therapy> selectedTherapies = [];
    try{
      selectedTherapyIndex = strategy.controllers[controllerKeyWithID]!.text
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
    return editable ? SizedBox(
      width: width*0.9,
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
              enabled: false,
              controller: strategy.controllers[controllerKeyWithID],
              onSaved: (value) {
                strategy.controllers[controllerKeyWithID]!.text = value!;
                strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
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
                strategy.controllers[controllerKeyWithID]!.text = selectedTherapyIndex.toString();
                strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: selectedTherapyIndex.toString());
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
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${strategy.controllers[controllerKeyWithID]!.text}');
  }


  Widget StrategyMultipleStrategyFormField(WidgetRef ref,StrategyParameters strategyParameter,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(strategy.id, controllerKey);
    List<int> selectedStrategyIndex = [];
    List<Strategy> selectedStrategies = [];
    try{
      selectedStrategyIndex = strategy.controllers[controllerKeyWithID]!.text
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
    return editable ? SizedBox(
      width: width*0.9,
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
              enabled: false,
              controller: strategy.controllers[controllerKeyWithID],
              onSaved: (value) {
                strategy.controllers[controllerKeyWithID]!.text = value!;
                strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
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
                strategy.controllers[controllerKeyWithID]!.text = selectedStrategyIndex.toString();
                strategy.controllers[controllerKeyWithID]!.value = TextEditingValue(text: selectedStrategyIndex.toString());
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
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${strategy.controllers[controllerKeyWithID]!.text}');
  }

  Widget StrategyDoubleMatrixFormField(String controllerKey, {double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(strategy.id, controllerKey);
    return editable
        ? SizedBox(
      width: width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Utils.getControllerKeyLabel(controllerKey)),SizedBox(
            // width: 60,
            child: ShadInputFormField(
              id: controllerKeyWithID,
              initialValue: strategy.controllers[controllerKeyWithID]!.text,
              controller: strategy.controllers[controllerKeyWithID],
              onSaved: (value) {
                // doublesByLocations[locationIndex][valueIndex] = double.tryParse(value) ?? 0.0;
                // strategy.controllers['$controllerKeyWithID-$locationIndex-$valueIndex']!.text = value;
                // strategy.controllers['$controllerKeyWithID-$locationIndex-$valueIndex']!.value = TextEditingValue(text: value);
              },
              // validator: (value) {
              //   return FormUtil.validateDoubleRange(context, value, lower: lower, upper: upper);
              // },
            ),
          ),
          // Table(
          //   border: TableBorder.all(),
          //   columnWidths: {for (int i = 0; i < matrix[0].length; i++) i: FlexColumnWidth()},
          //   children: List.generate(matrix.length, (rowIndex) {
          //     return TableRow(
          //       children: List.generate(matrix[rowIndex].length, (colIndex) {
          //         String cellKey = '$controllerKeyWithID-$rowIndex-$colIndex';
          //         TextEditingController cellController = TextEditingController(text: matrix[rowIndex][colIndex].toString());
          //         return Padding(
          //           padding: const EdgeInsets.all(4.0),
          //           child: TextFormField(
          //             controller: cellController,
          //             keyboardType: TextInputType.number,
          //             decoration: InputDecoration(border: OutlineInputBorder()),
          //             onChanged: (value) {
          //               double? newValue = double.tryParse(value);
          //               if (newValue != null) {
          //                 matrix[rowIndex][colIndex] = newValue;
          //               }
          //             },
          //             validator: (value) {
          //               return FormUtil.validateDoubleRange(context, value, lower:lower, upper: upper);
          //             },
          //           ),
          //         );
          //       }),
          //     );
          //   }),
          // ),
        ],
      ),
    )
        : Text(
        '${Utils.getControllerKeyLabel(controllerKey)}: ${strategy.controllers[controllerKeyWithID]!.text}');
  }

}
