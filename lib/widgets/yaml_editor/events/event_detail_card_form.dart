import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/models/strategy_parameters.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../models/events/event.dart';
import '../../../providers/ui_providers.dart';
import '../../../utils/form_validator.dart';
import '../../../utils/utils.dart';

class EventDetailCardForm {
  final BuildContext context;
  final Event event;
  final bool editable;
  final double width;
  final VoidCallback onUpdateUI;

  EventDetailCardForm(this.context, this.event, this.editable, this.width, this.onUpdateUI);

  Widget EventDateFormField(String controllerKey, {String dateID = ''}){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    String dateKey = dateID.isEmpty ? controllerKeyWithID : '${controllerKeyWithID}_$dateID';
    return editable ? SizedBox(
      width: width*0.9,
      child:ShadInputFormField(
        id: dateKey,
        label: Text(Utils.getControllerKeyLabel(dateKey)),
        placeholder: Text(event.controllers[dateKey]!.text),
        initialValue: event.controllers[dateKey]?.text,
        controller: event.controllers[dateKey],
        onSaved: (value) {
          event.controllers[dateKey]!.text = value!;
          event.controllers[dateKey]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDate(context, value);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(dateKey)}: ${event.controllers[dateKey]!.text}');
  }

  Widget EventDateFormFieldCustomLabel(String controllerKey, String label, {String dateID = ''}){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    String dateKey = dateID.isEmpty ? controllerKeyWithID : '${controllerKeyWithID}_$dateID';
    return editable ? SizedBox(
      width: width*0.9,
      child:ShadInputFormField(
        id: dateKey,
        label: Text(label),
        placeholder: Text(event.controllers[dateKey]!.text),
        initialValue: event.controllers[dateKey]?.text,
        controller: event.controllers[dateKey],
        onSaved: (value) {
          event.controllers[dateKey]!.text = value!;
          event.controllers[dateKey]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDate(context, value);
        },
      ),
    ) : Text('$label: ${event.controllers[dateKey]!.text}');
  }

  Widget EventDateFormFieldWithRemoval(String controllerKey, {String dateID = ''}){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    String dateKey = dateID.isEmpty ? controllerKeyWithID : '${controllerKeyWithID}_$dateID';
    return editable ? SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: width*0.9*0.75,
            child: ShadInputFormField(
              id: dateKey,
              label: Text(Utils.getControllerKeyLabel(dateKey)),
              placeholder: Text(event.controllers[dateKey]!.text),
              initialValue: event.controllers[dateKey]?.text,
              controller: event.controllers[dateKey],
              onSaved: (value) {
                // print('onSaved');
                event.controllers[dateKey]!.text = value!;
                event.controllers[dateKey]!.value = TextEditingValue(text: value);
              },
              validator: (value) {
                return FormUtil.validateDate(context, value);
              },
            ),
          ),
        ],
      ),
    ) : Text('${Utils.getControllerKeyLabel(dateKey)}: ${event.controllers[dateKey]!.text}');
  }

  Widget EventBoolFormField(String controllerKey, String boolText){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Utils.getControllerKeyLabel(controllerKey)),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width*0.9*0.15,
                child: ShadInputFormField(
                  id: '${controllerKeyWithID}_text',
                  initialValue: event.controllers[controllerKeyWithID]!.text.toString().toUpperCase(),
                  controller: event.controllers[controllerKeyWithID],
                  readOnly: true,
                  textAlign: TextAlign.center,
                  decoration: ShadDecoration(
                    border: ShadBorder.all(
                        color: ShadTheme.of(context).colorScheme.popoverForeground,
                        width: 1.0
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: width*0.9*0.15,
                // child: Text(event.controllers[controllerKeyWithID]!.text.toString()),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width*0.9*0.15,
                      child: ShadSwitchFormField(
                        id: controllerKeyWithID,
                        initialValue: event.controllers[controllerKeyWithID]!.text == 'true',
                        inputLabel: null,
                        padding: const EdgeInsets.only(left: 4),
                        onChanged: (value) {
                          event.controllers[controllerKeyWithID]!.text = value.toString();
                          event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value.toString());
                        },
                        onSaved: (value) {
                          event.controllers[controllerKeyWithID]!.text = value.toString();
                          event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value.toString());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: width*0.9*0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(boolText),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventIntegerFormField(String controllerKey, {int lower = -1, int upper = -1}){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: event.controllers[controllerKeyWithID]!.text,
        controller: event.controllers[controllerKeyWithID],
        onSaved: (value) {
          event.controllers[controllerKeyWithID]!.text = value!;
          event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateIntRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventSingleStrategyFormField(StrategyParameters strategyParameters,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    final initialStrategyKeyIndex = strategyParameters.strategies
        .indexWhere((strategy) => strategy.name == strategyParameters.strategyDb[int.parse(event.controllers[controllerKeyWithID]!.text)]!.name);
    final initialStrategy = strategyParameters.strategies[initialStrategyKeyIndex];
    return editable ? SizedBox(
      width: width*0.9,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180),
        child: ShadSelect<String>(
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
            ...strategyParameters.strategies
                .map((strategy){
              final strategyKeyIndex = strategyParameters.strategies
                  .indexWhere((element) => element.name == strategy.name);
                  return ShadOption(
                      value: strategy.name.toString(),
                      child: Text('$strategyKeyIndex: ${strategy.name}'));
            })
          ],
          initialValue: initialStrategy.name,
          selectedOptionBuilder: (context, value){
            final strategyKeyIndex = strategyParameters.strategies
                .indexWhere((strategy) => strategy.name == value);
            event.controllers[controllerKeyWithID]!.text = strategyKeyIndex.toString();
            event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: strategyKeyIndex.toString());
            return strategyParameters.strategies
                .map((strategy) {
              final strategyKeyIndex = strategyParameters.strategies
                  .indexWhere((element) => element.name == strategy.name);
              return ShadOption(
                  value: strategy.name.toString(),
                  child: Text('$strategyKeyIndex: ${strategy.name}'));})
                .toList()
                .firstWhere((option) => option.value == value);
          }),
        ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventDoubleFormField(String controllerKey, {double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: event.controllers[controllerKeyWithID]!.text,
        controller: event.controllers[controllerKeyWithID],
        onSaved: (value) {
          event.controllers[controllerKeyWithID]!.text = value!;
          event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDoubleRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventGenotypeFormField(String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: event.controllers[controllerKeyWithID]!.text,
        controller: event.controllers[controllerKeyWithID],
        onSaved: (value) {
          event.controllers[controllerKeyWithID]!.text = value!;
          event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateGenotype(context, value);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventDoubleArrayFormField(String controllerKey, {double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: event.controllers[controllerKeyWithID]!.text,
        controller: event.controllers[controllerKeyWithID],
        onSaved: (value) {
          event.controllers[controllerKeyWithID]!.text = value!;
          event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDoubleArrayRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${event.controllers[controllerKeyWithID]!.text}');
  }
}
