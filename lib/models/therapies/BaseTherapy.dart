

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:masimflow/models/therapies/therapy.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';

import '../../utils/utils.dart';
import '../../widgets/yaml_editor/therapies/therapy_detail_card_form.dart';

class BaseTherapy extends Therapy {
  BaseTherapy({
    required String id,
    required String name,
    List<int>? drugIds,
    List<int>? dosingDays,
    List<int>? therapyIds,
    List<int>? regimen,
    Map<String, TextEditingController> controllers = const {},
  }) : super(
    id: id,
    name: name,
    drugIds: drugIds,
    dosingDays: dosingDays,
    therapyIds: therapyIds,
    regimen: regimen,
    controllers: controllers,
  );

  @override
  BaseTherapyState createState() => BaseTherapyState();

  Therapy copy(){
    String newId = Uuid().v4();
    Map<String,TextEditingController> newControllers = {};
    controllers.forEach((key, value) {
      String newKey = key.replaceAll(id, newId);
      newControllers[newKey] = TextEditingController(text: value.text);
    });
    return BaseTherapy(
      id: newId,
      name: name,
      drugIds: drugIds,
      dosingDays: dosingDays,
      therapyIds: therapyIds,
      regimen: regimen,
      controllers: newControllers,
    );
  }
}

class BaseTherapyState extends TherapyState<Therapy> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.formWidth * 0.85,
      child: ShadForm(
        key: widget.formKey,
        enabled: widget.formEditable,
        autovalidateMode: ShadAutovalidateMode.always,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            TherapyDetailCardForm(
                type: TherapyDetailCardFormType.string,
                controllerKey: 'name',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                therapy: widget
            ),
            widget.isMAC ? TherapyDetailCardForm(
                type: TherapyDetailCardFormType.multipleTherapy,
                controllerKey: 'therapy_ids',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                therapy: widget,
                therapyMap: ref.read(therapyTemplateMapProvider.notifier).get()
            ) : TherapyDetailCardForm(
                type: TherapyDetailCardFormType.multipleDrug,
                controllerKey: 'drug_ids',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                therapy: widget,
                drugMap: ref.read(drugMapProvider.notifier).get()
            ),
            widget.isMAC ? TherapyDetailCardForm(
              type: TherapyDetailCardFormType.integerArray,
              controllerKey: 'regimen',
              editable: widget.formEditable,
              width: widget.formWidth * 0.85,
              therapy: widget,
              lower: 0.0,
              upper: -1.0,
            ) : TherapyDetailCardForm(
                type: TherapyDetailCardFormType.integerArray,
                controllerKey: 'dosing_days',
                editable: widget.formEditable,
                width: widget.formWidth * 0.85,
                therapy: widget,
                lower: 0.0,
                upper: -1.0,
            ),
          ],
        ),
      ),
    );
  }
}