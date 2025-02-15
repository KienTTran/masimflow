import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/strategies/strategy.dart';
import 'package:masimflow/models/strategy_parameters.dart';
import 'package:masimflow/models/therapy.dart';
import 'package:masimflow/widgets/yaml_editor/strategies/strategy_detail_card_form.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../models/events/event.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/ui_providers.dart';
import '../../../utils/form_validator.dart';
import '../../../utils/utils.dart';
import '../strategies/strategy_detail_card.dart';

enum EventDetailCardFormType{
  integer,
  double,
  bool,
  date,
  genotype,
  doubleArray,
  singleStrategy,
  dateWithRemoval,
  dateCustomLabel,
}

class EventDetailCardForm extends ConsumerStatefulWidget {
  final EventDetailCardFormType type;
  final String controllerKey;
  final Event event;
  bool editable = false;
  final double width;
  String? dateID = '';
  String? dateLabel = '';
  String? boolText = '';
  double? lower = -1.0;
  double? upper= -1.0;
  StrategyParameters? strategyParameters;

  EventDetailCardForm({
    required this.type,
    required this.controllerKey,
    required this.event,
    required this.editable,
    required this.width,
    this.dateID,
    this.dateLabel,
    this.boolText,
    this.lower,
    this.upper,
    this.strategyParameters,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => EventDetailCardFormState();
}

class EventDetailCardFormState extends ConsumerState<EventDetailCardForm>{
  Strategy? currentStrategy;
  List<Therapy> currentStrategyTherapies = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(widget.type){
      case EventDetailCardFormType.integer:
        return EventIntegerFormField(widget.controllerKey, lower: widget.lower!.toInt(), upper: widget.upper!.toInt());
      case EventDetailCardFormType.double:
        return EventDoubleFormField(widget.controllerKey, lower: widget.lower!, upper: widget.upper!);
      case EventDetailCardFormType.bool:
        return EventBoolFormField(widget.controllerKey, widget.boolText!);
      case EventDetailCardFormType.date:
        return EventDateFormField(widget.controllerKey, dateID: widget.dateID!);
      case EventDetailCardFormType.genotype:
        return EventGenotypeFormField(widget.controllerKey);
      case EventDetailCardFormType.doubleArray:
        return EventDoubleArrayFormField(widget.controllerKey, lower: widget.lower!, upper: widget.upper!);
      case EventDetailCardFormType.singleStrategy:
        return EventSingleStrategyFormField(widget.strategyParameters!, widget.controllerKey);
      case EventDetailCardFormType.dateWithRemoval:
        return EventDateFormFieldWithRemoval(widget.controllerKey, dateID: widget.dateID!);
      case EventDetailCardFormType.dateCustomLabel:
        return EventDateFormFieldCustomLabel(widget.controllerKey, widget.dateLabel!, dateID: widget.dateID!);
      default:
        return Text('Invalid Form Type');
    }
  }

  Widget EventDateFormField(String controllerKey, {String dateID = ''}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.event.id, controllerKey);
    String dateKey = dateID.isEmpty ? controllerKeyWithID : '${controllerKeyWithID}_$dateID';
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child:ShadInputFormField(
        id: dateKey,
        label: Text(Utils.getControllerKeyLabel(dateKey)),
        placeholder: Text(widget.event.controllers[dateKey]!.text),
        initialValue: widget.event.controllers[dateKey]?.text,
        controller: widget.event.controllers[dateKey],
        onSaved: (value) {
          widget.event.controllers[dateKey]!.text = value!;
          widget.event.controllers[dateKey]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDate(context, value);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(dateKey)}: ${widget.event.controllers[dateKey]!.text}');
  }

  Widget EventDateFormFieldCustomLabel(String controllerKey, String label, {String dateID = ''}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.event.id, controllerKey);
    String dateKey = dateID.isEmpty ? controllerKeyWithID : '${controllerKeyWithID}_$dateID';
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child:ShadInputFormField(
        id: dateKey,
        label: Text(label),
        placeholder: Text(widget.event.controllers[dateKey]!.text),
        initialValue: widget.event.controllers[dateKey]?.text,
        controller: widget.event.controllers[dateKey],
        onSaved: (value) {
          widget.event.controllers[dateKey]!.text = value!;
          widget.event.controllers[dateKey]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDate(context, value);
        },
      ),
    ) : Text('$label: ${widget.event.controllers[dateKey]!.text}');
  }

  Widget EventDateFormFieldWithRemoval(String controllerKey, {String dateID = ''}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.event.id, controllerKey);
    String dateKey = dateID.isEmpty ? controllerKeyWithID : '${controllerKeyWithID}_$dateID';
    return widget.editable ? SizedBox(
      width: widget.width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: widget.width*0.9*0.75,
            child: ShadInputFormField(
              id: dateKey,
              label: Text(Utils.getControllerKeyLabel(dateKey)),
              placeholder: Text(widget.event.controllers[dateKey]!.text),
              initialValue: widget.event.controllers[dateKey]?.text,
              controller: widget.event.controllers[dateKey],
              onSaved: (value) {
                // print('onSaved');
                widget.event.controllers[dateKey]!.text = value!;
                widget.event.controllers[dateKey]!.value = TextEditingValue(text: value);
              },
              validator: (value) {
                return FormUtil.validateDate(context, value);
              },
            ),
          ),
        ],
      ),
    ) : Text('${Utils.getControllerKeyLabel(dateKey)}: ${widget.event.controllers[dateKey]!.text}');
  }

  Widget EventBoolFormField(String controllerKey, String boolText){
    String controllerKeyWithID = Utils.getFormKeyID(widget.event.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
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
                width: widget.width*0.9*0.2,
                child: ShadInputFormField(
                  id: '${controllerKeyWithID}_text',
                  initialValue: widget.event.controllers[controllerKeyWithID]!.text.toString().toUpperCase(),
                  controller: widget.event.controllers[controllerKeyWithID],
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
                width: widget.width*0.9*0.15,
                // child: Text(widget.event.controllers[controllerKeyWithID]!.text.toString()),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: widget.width*0.9*0.15,
                      child: ShadSwitchFormField(
                        id: controllerKeyWithID,
                        initialValue: widget.event.controllers[controllerKeyWithID]!.text == 'true',
                        inputLabel: null,
                        padding: const EdgeInsets.only(left: 4),
                        onChanged: (value) {
                          widget.event.controllers[controllerKeyWithID]!.text = value.toString();
                          widget.event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value.toString());
                        },
                        onSaved: (value) {
                          widget.event.controllers[controllerKeyWithID]!.text = value.toString();
                          widget.event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value.toString());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: widget.width*0.9*0.6,
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
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventIntegerFormField(String controllerKey, {int lower = -1, int upper = -1}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.event.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.event.controllers[controllerKeyWithID]!.text,
        controller: widget.event.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.event.controllers[controllerKeyWithID]!.text = value!;
          widget.event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateIntRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventSingleStrategyFormField(StrategyParameters strategyParameters,String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(widget.event.id, controllerKey);
    final initialStrategyKeyIndex = strategyParameters.strategies
        .indexWhere((strategy) => strategy.name == strategyParameters.strategyDb[int.parse(widget.event.controllers[controllerKeyWithID]!.text)]!.name);
    final initialStrategy = strategyParameters.strategies[initialStrategyKeyIndex];
    ShadPopoverController controller = ShadPopoverController();
    currentStrategyTherapies = Utils.getTherapies(ref.read(therapyMapProvider.notifier).get(), strategyParameters, initialStrategy);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180),
            child: ShadSelect<String>(
                controller: controller,
                enabled: widget.editable,
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
                        child: Text('$strategyKeyIndex: ${strategy.name} (${strategy.type.typeAsString})'));
                  })
                ],
                initialValue: initialStrategy.name,
                onChanged: (value) {
                  final strategyKeyIndex = strategyParameters.strategies
                      .indexWhere((element) => element.name == value);
                  setState(() {
                    widget.event.controllers[controllerKeyWithID]!.text = strategyKeyIndex.toString();
                    widget.event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: strategyKeyIndex.toString());
                    currentStrategyTherapies = Utils.getTherapies(ref.read(therapyMapProvider.notifier).get(),
                        strategyParameters, strategyParameters.strategies[strategyKeyIndex]);
                    currentStrategy = strategyParameters.strategies[strategyKeyIndex];
                  });
                },
                selectedOptionBuilder: (context, value){
                  return strategyParameters.strategies
                      .map((strategy) {
                    final strategyKeyIndex = strategyParameters.strategies
                        .indexWhere((element) => element.name == strategy.name);
                    return ShadOption(
                        value: strategy.name.toString(),
                        child: Text('$strategyKeyIndex: ${strategy.name} (${strategy.type.typeAsString})'));})
                      .toList()
                      .firstWhere((option) => option.value == value);
                }),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Therapies:'),
                      Text(
                        currentStrategyTherapies.map((therapy) => therapy.name).join(', '),
                        softWrap: true, // Allow text to wrap
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5, // Limit the number of lines if necessary
                      ),
                    ],
                  ),
                ),
              ),
              ShadButton.outline(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  showShadSheet(
                    context: context,
                    side: ShadSheetSide.right,
                    isDismissible: false,
                    builder: (context) {
                      return ShadSheet(
                        constraints: const BoxConstraints(maxWidth: 512),
                        title: Text(Utils.getCapitalizedWords(widget.event.name)),
                        closeIcon: SizedBox(),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Material(
                                child: StrategyDetailCard(
                                  strategyID: currentStrategy != null ? currentStrategy!.id : initialStrategy.id,
                                  width: 512,
                                  height: MediaQuery.of(context).size.height,
                                  editable: true,
                                  popBack: () {
                                    setState(() {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventDoubleFormField(String controllerKey, {double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.event.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.event.controllers[controllerKeyWithID]!.text,
        controller: widget.event.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.event.controllers[controllerKeyWithID]!.text = value!;
          widget.event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDoubleRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventGenotypeFormField(String controllerKey){
    String controllerKeyWithID = Utils.getFormKeyID(widget.event.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.event.controllers[controllerKeyWithID]!.text,
        controller: widget.event.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.event.controllers[controllerKeyWithID]!.text = value!;
          widget.event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateGenotype(context, value);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventDoubleArrayFormField(String controllerKey, {double lower = -1.0, double upper = -1.0}){
    String controllerKeyWithID = Utils.getFormKeyID(widget.event.id, controllerKey);
    return widget.editable ? SizedBox(
      width: widget.width*0.9,
      child: ShadInputFormField(
        id: controllerKeyWithID,
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        initialValue: widget.event.controllers[controllerKeyWithID]!.text,
        controller: widget.event.controllers[controllerKeyWithID],
        onSaved: (value) {
          widget.event.controllers[controllerKeyWithID]!.text = value!;
          widget.event.controllers[controllerKeyWithID]!.value = TextEditingValue(text: value);
        },
        validator: (value) {
          return FormUtil.validateDoubleArrayRange(context, value, lower: lower, upper: upper);
        },
      ),
    ) : Text('${Utils.getControllerKeyLabel(controllerKey)}: ${widget.event.controllers[controllerKeyWithID]!.text}');
  }
}