import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/events/event.dart';
import '../../providers/ui_providers.dart';
import '../../utils/form_validator.dart';
import '../../utils/utils.dart';

class EventDetailCardForm {
  BuildContext context;
  Event event;
  bool editable;
  double width;

  EventDetailCardForm(this.context, this.event, this.editable, this.width);

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
        },
        validator: (value) {
          event.controllers[dateKey]!.text = value;
          return FormUtil.validateDate(context, value);
        },
      ),
    ) : Text('$dateKey : ${event.controllers[dateKey]!.text}');
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
        },
        validator: (value) {
          event.controllers[dateKey]!.text = value;
          return FormUtil.validateDate(context, value);
        },
      ),
    ) : Text('$dateKey : ${event.controllers[dateKey]!.text}');
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
              },
              validator: (value) {
                event.controllers[dateKey]!.text = value;
                return FormUtil.validateDate(context, value);
              },
            ),
          ),
        ],
      ),
    ) : Text('$dateKey : ${event.controllers[dateKey]!.text}');
  }

  Widget EventBoolFormField(String controllerKey, String boolText){
    String controllerKeyWithID = Utils.getFormKeyID(event.id, controllerKey);
    return editable ? SizedBox(
      width: width*0.9,
      child: ShadSwitchFormField(
        id: controllerKeyWithID,
        initialValue: event.controllers[controllerKeyWithID]!.text == 'true' ? true : false,
        inputLabel: Text(event.controllers[controllerKeyWithID]!.text),
        label: Text(Utils.getControllerKeyLabel(controllerKey)),
        onChanged: (value) {
          event.controllers[controllerKeyWithID]!.text = value.toString();
        },
        onSaved: (value) {
          event.controllers[controllerKeyWithID]!.text = value.toString();
        },
        inputSublabel: Text(boolText),
      ),
    ) : Text('$controllerKeyWithID : ${event.controllers[controllerKeyWithID]!.text}');
  }

  Widget EventIntFormField(String controllerKey, dynamic value,{int lower = 0, int upper = 100}){
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
        },
        validator: (value) {
          event.controllers[controllerKeyWithID]!.text = value;
          return FormUtil.validateIntRange(context, lower, upper, value);
        },
      ),
    ) : Text('$controllerKeyWithID : $value');
  }

  Widget EventDoubleFormField(String controllerKey, dynamic value, {double lower = 0.0, double upper = 1.0}){
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
        },
        validator: (value) {
          event.controllers[controllerKeyWithID]!.text = value;
          return FormUtil.validateDoubleRange(context, lower, upper, value);
        },
      ),
    ) : Text('$controllerKeyWithID : $value');
  }

  Widget EventGenotypeFormField(String controllerKey, dynamic value, {double lower = 0.0, double upper = 1.0}){
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
        },
        validator: (value) {
          event.controllers[controllerKeyWithID]!.text = value;
          return FormUtil.validateGenotype(context, value);
        },
      ),
    ) : Text('$controllerKeyWithID : $value');
  }

  Widget EventDoubleArrayFormField(String controllerKey, dynamic value){
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
        },
        validator: (value) {
          event.controllers[controllerKeyWithID]!.text = value;
          return FormUtil.validateDoubleArrayRange(context, 0.0, 1.0, value);
        },
      ),
    ) : Text('$controllerKeyWithID : $value');
  }

}
