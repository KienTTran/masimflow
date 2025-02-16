import 'package:flutter/material.dart';
import 'package:masimflow/models/events/event.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:uuid/uuid.dart';
import '../../utils/utils.dart';
import '../../widgets/yaml_editor/events/event_detail_card_form.dart';

enum TreatmentCoverageType {
  SteadyTCM,
  InflatedTCM,
  LinearTCM;

  String get label {
    return switch (this) {
      SteadyTCM => 'SteadyTCM',
      InflatedTCM => 'InflatedTCM',
      LinearTCM => 'LinearTCM',
    };
  }
}

/// Base interface for treatment coverage data.
abstract class TreatmentCoverage {
  final String id = const Uuid().v4();
  List<DateTime> get dates;
  TreatmentCoverage copy();
  String type();
}

/// Represents a steady treatment coverage change.
class SteadyTreatmentCoverage implements TreatmentCoverage {
  final String id = const Uuid().v4();
  DateTime date;
  List<double> pTreatmentUnder5ByLocation;
  List<double> pTreatmentOver5ByLocation;

  SteadyTreatmentCoverage({
    required this.date,
    required this.pTreatmentUnder5ByLocation,
    required this.pTreatmentOver5ByLocation,
  });

  @override
  List<DateTime> get dates => [date];

  @override
  String type() => TreatmentCoverageType.SteadyTCM.label;

  factory SteadyTreatmentCoverage.fromYaml(Map<dynamic, dynamic> map) {
    DateTime date = DateFormat('yyyy/MM/dd').parse(map['date']);
    List<double> under5 = List<double>.from((map['p_treatment_under_5_by_location'] ?? []).map((e) => (e as num).toDouble()));
    List<double> over5 = List<double>.from((map['p_treatment_over_5_by_location'] ?? []).map((e) => (e as num).toDouble()));

    return SteadyTreatmentCoverage(
      date: date,
      pTreatmentUnder5ByLocation: under5,
      pTreatmentOver5ByLocation: over5,
    );
  }

  @override
  SteadyTreatmentCoverage copy() {
    return SteadyTreatmentCoverage(
      date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      pTreatmentUnder5ByLocation: List<double>.from(pTreatmentUnder5ByLocation),
      pTreatmentOver5ByLocation: List<double>.from(pTreatmentOver5ByLocation),
    );
  }
}

/// Represents an inflated treatment coverage change.
class InflatedTreatmentCoverage implements TreatmentCoverage {
  final String id = const Uuid().v4();
  DateTime date;
  double annualInflationRate;

  InflatedTreatmentCoverage({
    required this.date,
    required this.annualInflationRate,
  });

  @override
  List<DateTime> get dates => [date];

  @override
  String type() => TreatmentCoverageType.InflatedTCM.label;

  factory InflatedTreatmentCoverage.fromYaml(Map<dynamic, dynamic> map) {
    DateTime date = DateFormat('yyyy/MM/dd').parse(map['date']);
    double inflationRate = (map['annual_inflation_rate'] ?? 0.0).toDouble();

    return InflatedTreatmentCoverage(
      date: date,
      annualInflationRate: inflationRate,
    );
  }

  @override
  InflatedTreatmentCoverage copy() {
    return InflatedTreatmentCoverage(
      date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      annualInflationRate: annualInflationRate,
    );
  }
}

/// Represents a linear treatment coverage change.
class LinearTreatmentCoverage implements TreatmentCoverage {
  final String id = const Uuid().v4();
  DateTime fromDate;
  DateTime toDate;
  List<double> pTreatmentUnder5ByLocationTo;
  List<double> pTreatmentOver5ByLocationTo;

  LinearTreatmentCoverage({
    required this.fromDate,
    required this.toDate,
    required this.pTreatmentUnder5ByLocationTo,
    required this.pTreatmentOver5ByLocationTo,
  });

  @override
  List<DateTime> get dates => [fromDate, toDate];

  @override
  String type() => TreatmentCoverageType.LinearTCM.label;

  factory LinearTreatmentCoverage.fromYaml(Map<dynamic, dynamic> map) {
    DateTime fromDate = DateFormat('yyyy/MM/dd').parse(map['from_date']);
    DateTime toDate = DateFormat('yyyy/MM/dd').parse(map['to_date']);
    List<double> under5To = List<double>.from((map['p_treatment_under_5_by_location_to'] ?? []).map((e) => (e as num).toDouble()));
    List<double> over5To = List<double>.from((map['p_treatment_over_5_by_location_to'] ?? []).map((e) => (e as num).toDouble()));

    return LinearTreatmentCoverage(
      fromDate: fromDate,
      toDate: toDate,
      pTreatmentUnder5ByLocationTo: under5To,
      pTreatmentOver5ByLocationTo: over5To,
    );
  }

  @override
  LinearTreatmentCoverage copy() {
    return LinearTreatmentCoverage(
      fromDate: DateTime.fromMillisecondsSinceEpoch(fromDate.millisecondsSinceEpoch),
      toDate: DateTime.fromMillisecondsSinceEpoch(toDate.millisecondsSinceEpoch),
      pTreatmentUnder5ByLocationTo: List<double>.from(pTreatmentUnder5ByLocationTo),
      pTreatmentOver5ByLocationTo: List<double>.from(pTreatmentOver5ByLocationTo),
    );
  }
}

/// Event representing treatment coverage changes.
class ChangeTreatmentCoverage extends Event {
  List<TreatmentCoverage> coverages;

  ChangeTreatmentCoverage({
    required String id,
    required String name,
    required Map<String, TextEditingController> controllers,
    required this.coverages,
  }) : super(id: id, name: name, controllers: controllers);

  factory ChangeTreatmentCoverage.fromYaml(Map<dynamic, dynamic> yaml) {
    final String id = const Uuid().v4();
    final String name = yaml['name'];
    final List infoList = yaml['info'] as List;

    List<TreatmentCoverage> coverages = [];
    Map<String, TextEditingController> controllers = {};

    for (var item in infoList) {
      final String type = item['type'];
      TreatmentCoverage coverage;

      switch (type) {
        case 'SteadyTCM':
          coverage = SteadyTreatmentCoverage.fromYaml(item);
          break;
        case 'InflatedTCM':
          coverage = InflatedTreatmentCoverage.fromYaml(item);
          break;
        case 'LinearTCM':
          coverage = LinearTreatmentCoverage.fromYaml(item);
          break;
        default:
          throw Exception('Unknown TreatmentCoverage type: $type');
      }
      coverages.add(coverage);
    }

    for(int i = 0; i < coverages.length; i++){
      for(int j = 0; j < coverages[i].dates.length; j++){
        int index = j;
        String keyID = Utils.getFormKeyID(id, '${coverages[i].id}#date_$index');
        controllers[keyID] = TextEditingController(
          text: DateFormat('yyyy/MM/dd').format(coverages[i].dates[j]),
        );
      }
      if(coverages[i] is SteadyTreatmentCoverage){
        for(int j = 0; j < (coverages[i] as SteadyTreatmentCoverage).pTreatmentUnder5ByLocation.length; j++){
          int index = j;
          String keyID = Utils.getFormKeyID(id, '${coverages[i].id}#p_treatment_under_5_by_location');
          controllers[keyID] = TextEditingController(
            text: (coverages[i] as SteadyTreatmentCoverage).pTreatmentUnder5ByLocation[j].toString(),
          );
        }
        for(int j = 0; j < (coverages[i] as SteadyTreatmentCoverage).pTreatmentOver5ByLocation.length; j++){
          int index = j;
          String keyID = Utils.getFormKeyID(id, '${coverages[i].id}#p_treatment_over_5_by_location');
          controllers[keyID] = TextEditingController(
            text: (coverages[i] as SteadyTreatmentCoverage).pTreatmentOver5ByLocation[j].toString(),
          );
        }
      }
      if(coverages[i] is LinearTreatmentCoverage){
        for(int j = 0; j < (coverages[i] as LinearTreatmentCoverage).pTreatmentUnder5ByLocationTo.length; j++){
          String keyID = Utils.getFormKeyID(id, '${coverages[i].id}#p_treatment_under_5_by_location_to');
          controllers[keyID] = TextEditingController(
            text: (coverages[i] as LinearTreatmentCoverage).pTreatmentUnder5ByLocationTo[j].toString(),
          );
        }
        for(int j = 0; j < (coverages[i] as LinearTreatmentCoverage).pTreatmentOver5ByLocationTo.length; j++){
          String keyID = Utils.getFormKeyID(id, '${coverages[i].id}#p_treatment_over_5_by_location_to');
          controllers[keyID] = TextEditingController(
            text: (coverages[i] as LinearTreatmentCoverage).pTreatmentOver5ByLocationTo[j].toString(),
          );
        }
      }
      if(coverages[i] is InflatedTreatmentCoverage){
        String keyID = Utils.getFormKeyID(id, '${coverages[i].id}#annual_inflation_rate');
        controllers[keyID] = TextEditingController(
          text: (coverages[i] as InflatedTreatmentCoverage).annualInflationRate.toString(),
        );
      }
      controllers[Utils.getFormKeyID(id, 'type')] = TextEditingController(
        text: coverages[i].type(),
      );
    }

    // print('ChangeTreatmentCoverage fromYaml:');
    // print(controllers.keys);

    return ChangeTreatmentCoverage(
      id: id,
      name: name,
      controllers: controllers,
      coverages: coverages.toList(),
    );
  }

  @override
  ChangeTreatmentCoverage copy() {
    //
    // print('Before copy:');
    // print('id: $id');
    // print('controllers: $controllers');
    // print('dates: ${dates().toString()}');
    // print('coverages dates: ${coverages.map((coverage) => coverage.dates)}');
    // print(coverages.map( (coverage) => coverage.id));

    final newId = const Uuid().v4();
    final newCoverages = coverages.map((coverage) => coverage.copy()).toList();
    Map<String,TextEditingController> newControllers = {};

    for(int i = 0; i < newCoverages.length; i++){
      for(int j = 0; j < newCoverages[i].dates.length; j++){
        int index = j;
        String keyID = Utils.getFormKeyID(newId, '${newCoverages[i].id}#date_$index');
        newControllers[keyID] = TextEditingController(
          text: DateFormat('yyyy/MM/dd').format(newCoverages[i].dates[j]),
        );
      }
      if(newCoverages[i] is SteadyTreatmentCoverage){
        String keyID = Utils.getFormKeyID(newId, '${newCoverages[i].id}#p_treatment_under_5_by_location');
        String dataListString = (newCoverages[i] as SteadyTreatmentCoverage).pTreatmentUnder5ByLocation.toString();
        dataListString = Utils.removeExtraChars(dataListString);
        newControllers[keyID] = TextEditingController(text: dataListString);
        keyID = Utils.getFormKeyID(newId, '${newCoverages[i].id}#p_treatment_over_5_by_location');
        dataListString = (newCoverages[i] as SteadyTreatmentCoverage).pTreatmentOver5ByLocation.toString();
        dataListString = Utils.removeExtraChars(dataListString);
        newControllers[keyID] = TextEditingController(text: dataListString);
      }
      if(newCoverages[i] is LinearTreatmentCoverage){
        String keyID = Utils.getFormKeyID(newId, '${newCoverages[i].id}#p_treatment_under_5_by_location_to');
        String dataListString = (newCoverages[i] as LinearTreatmentCoverage).pTreatmentUnder5ByLocationTo.toString();
        dataListString = Utils.removeExtraChars(dataListString);
        newControllers[keyID] = TextEditingController(text: dataListString);
        keyID = Utils.getFormKeyID(newId, '${newCoverages[i].id}#p_treatment_over_5_by_location_to');
        dataListString = (newCoverages[i] as LinearTreatmentCoverage).pTreatmentOver5ByLocationTo.toString();
        dataListString = Utils.removeExtraChars(dataListString);
        newControllers[keyID] = TextEditingController(text: dataListString);
      }
      if(newCoverages[i] is InflatedTreatmentCoverage){
        String keyID = Utils.getFormKeyID(newId, '${newCoverages[i].id}#annual_inflation_rate');
        String dataString = (newCoverages[i] as InflatedTreatmentCoverage).annualInflationRate.toString();
        newControllers[keyID] = TextEditingController(text: dataString);
      }
      newControllers[Utils.getFormKeyID(newId, 'type')] = TextEditingController(
        text: newCoverages[i].type(),
      );
    }
    update();
    //
    // print('After copy:');
    // print('newId: $newId');
    // print('newControllers: $newControllers');
    // print('newDates: ${dates().toString()}');
    // print('newCoverage newDates: ${newCoverages.map((coverage) => coverage.dates)}');
    // print(newCoverages.map( (coverage) => coverage.id));

    return ChangeTreatmentCoverage(
      id: newId,
      name: name,
      controllers: newControllers,
      coverages: newCoverages,
    );
  }

  @override
  void addEntry() {
    TreatmentCoverageType type = controllers[Utils.getFormKeyID(id, 'type')]!.text == TreatmentCoverageType.SteadyTCM.label
        ? TreatmentCoverageType.SteadyTCM
        : controllers[Utils.getFormKeyID(id, 'type')]!.text == TreatmentCoverageType.InflatedTCM.label
        ? TreatmentCoverageType.InflatedTCM
        : TreatmentCoverageType.LinearTCM;
    switch(type){
      case TreatmentCoverageType.SteadyTCM:
        {
          SteadyTreatmentCoverage coverage = SteadyTreatmentCoverage(
            date: DateTime.now(),
            pTreatmentUnder5ByLocation: [0,0],
            pTreatmentOver5ByLocation: [0.0],
          );
          coverage.dates.asMap().forEach((index,date){
            controllers[Utils.getFormKeyID(id, '${coverage.id}#date_$index')] =
                TextEditingController(
                  text: DateFormat('yyyy/MM/dd').format(date),
                );
          });
          coverage.pTreatmentUnder5ByLocation.forEach((value) {
            controllers[Utils.getFormKeyID(
                id, '${coverage.id}#p_treatment_under_5_by_location')] =
                TextEditingController(
                  text: value.toString(),
                );
          });
          coverage.pTreatmentOver5ByLocation.forEach((value) {
            controllers[Utils.getFormKeyID(
                id, '${coverage.id}#p_treatment_over_5_by_location')] =
                TextEditingController(
                  text: value.toString(),
                );
          });
          coverages.add(coverage);
          break;
        }
      case TreatmentCoverageType.InflatedTCM:
        {
          InflatedTreatmentCoverage coverage = InflatedTreatmentCoverage(
            date: DateTime.now(),
            annualInflationRate: 0.0,
          );
          coverage.dates.asMap().forEach((index,date){
            controllers[Utils.getFormKeyID(id, '${coverage.id}#date_$index')] =
                TextEditingController(
                  text: DateFormat('yyyy/MM/dd').format(date),
                );
          });
          controllers[Utils.getFormKeyID(
              id, '${coverage.id}#annual_inflation_rate')] =
              TextEditingController(
                text: coverage.annualInflationRate.toString(),
              );
          coverages.add(coverage);
          break;
        }
      case TreatmentCoverageType.LinearTCM:
        {
          LinearTreatmentCoverage coverage = LinearTreatmentCoverage(
            fromDate: DateTime.now(),
            toDate: DateTime.now(),
            pTreatmentUnder5ByLocationTo: [0.0],
            pTreatmentOver5ByLocationTo: [0.0],
          );
          coverage.dates.asMap().forEach((index,date){
            controllers[Utils.getFormKeyID(id, '${coverage.id}#date_$index')] =
                TextEditingController(
                  text: DateFormat('yyyy/MM/dd').format(date),
                );
          });
          coverage.pTreatmentUnder5ByLocationTo.forEach((value) {
            controllers[Utils.getFormKeyID(
                id, '${coverage.id}#p_treatment_under_5_by_location_to')] =
                TextEditingController(
                  text: value.toString(),
                );
          });
          coverage.pTreatmentOver5ByLocationTo.forEach((value) {
            controllers[Utils.getFormKeyID(
                id, '${coverage.id}#p_treatment_over_5_by_location_to')] =
                TextEditingController(
                  text: value.toString(),
                );
          });
          coverages.add(coverage);
          break;
        }
    }
  }

  @override
  void deleteEntry() {
    // print('before delete entry ${controllers.keys.length}');

    TreatmentCoverage lastCoverage = coverages.last;
    if (lastCoverage is SteadyTreatmentCoverage) {
      for (int i = 0; i < lastCoverage.dates.length; i++) {
        controllers.remove(Utils.getFormKeyID(id, '${lastCoverage.id}#date_$i'));
      }
      for (int i = 0; i < lastCoverage.pTreatmentUnder5ByLocation.length; i++) {
        controllers.remove(Utils.getFormKeyID(id, '${lastCoverage.id}#p_treatment_under_5_by_location'));
      }
      for (int i = 0; i < lastCoverage.pTreatmentOver5ByLocation.length; i++) {
        controllers.remove(Utils.getFormKeyID(id, '${lastCoverage.id}#p_treatment_over_5_by_location'));
      }
    }
    if (lastCoverage is InflatedTreatmentCoverage) {
      for (int i = 0; i < lastCoverage.dates.length; i++) {
        controllers.remove(Utils.getFormKeyID(id, '${lastCoverage.id}#date_$i'));
      }
      controllers.remove(Utils.getFormKeyID(id, '${lastCoverage.id}#annual_inflation_rate'));
    }
    if (lastCoverage is LinearTreatmentCoverage) {
      for (int i = 0; i < lastCoverage.dates.length; i++) {
        controllers.remove(Utils.getFormKeyID(id, '${lastCoverage.id}#date_$i'));
      }
      for (int i = 0; i < lastCoverage.pTreatmentUnder5ByLocationTo.length; i++) {
        controllers.remove(Utils.getFormKeyID(id, '${lastCoverage.id}#p_treatment_under_5_by_location_to'));
      }
      for (int i = 0; i < lastCoverage.pTreatmentOver5ByLocationTo.length; i++) {
        controllers.remove(Utils.getFormKeyID(id, '${lastCoverage.id}#p_treatment_over_5_by_location_to'));
      }
    }
    coverages.removeLast();

    // print('after delete entry ${controllers.keys.length}');
    update();
  }

  @override
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'info': coverages.map((coverage) {
        if (coverage is SteadyTreatmentCoverage) {
          return {
            'type': TreatmentCoverageType.SteadyTCM.label,
            'date': DateFormat('yyyy/MM/dd').format(coverage.date),
            'p_treatment_under_5_by_location': coverage.pTreatmentUnder5ByLocation,
            'p_treatment_over_5_by_location': coverage.pTreatmentOver5ByLocation,
          };
        } else if (coverage is InflatedTreatmentCoverage) {
          return {
            'type': TreatmentCoverageType.InflatedTCM.label,
            'date': DateFormat('yyyy/MM/dd').format(coverage.date),
            'annual_inflation_rate': coverage.annualInflationRate,
          };
        } else if (coverage is LinearTreatmentCoverage) {
          return {
            'type': TreatmentCoverageType.LinearTCM.label,
            'from_date': DateFormat('yyyy/MM/dd').format(coverage.fromDate),
            'to_date': DateFormat('yyyy/MM/dd').format(coverage.toDate),
            'p_treatment_under_5_by_location_to': coverage.pTreatmentUnder5ByLocationTo,
            'p_treatment_over_5_by_location_to': coverage.pTreatmentOver5ByLocationTo,
          };
        }
        return {};
      }).toList(),
    };
  }

  @override
  void update() {
    // print('Coverages dates before update:');
    // coverages.forEach((coverage) => print(coverage.dates));
    // update dates of all coverage from controllers
    for (int i = 0; i < coverages.length; i++) {
      for(int j = 0; j < controllers.length; j++){
        String controllerKey = controllers.keys.elementAt(j);
        if(controllerKey.contains(coverages[i].id)){
          // print('coverage ${coverages[i].type()} controllerKey: $controllerKey');
          if(controllerKey.contains('date')){
            int index = int.parse(controllerKey.split('_').last);
            if(coverages[i] is SteadyTreatmentCoverage){
              (coverages[i] as SteadyTreatmentCoverage).date = DateFormat('yyyy/MM/dd').parse(controllers[controllerKey]!.text);
            }
            if(coverages[i] is LinearTreatmentCoverage){
              (coverages[i] as LinearTreatmentCoverage).dates[index] = DateFormat('yyyy/MM/dd').parse(controllers[controllerKey]!.text);
            }
            if(coverages[i] is InflatedTreatmentCoverage){
              (coverages[i] as InflatedTreatmentCoverage).date = DateFormat('yyyy/MM/dd').parse(controllers[controllerKey]!.text);
            }
          }
          else{
            if(coverages[i] is SteadyTreatmentCoverage){
              // print('update: $controllerKey ${controllers[controllerKey]!.text}');
              if(controllerKey.contains('p_treatment_under_5_by_location')){
                (coverages[i] as SteadyTreatmentCoverage).pTreatmentUnder5ByLocation = List<double>.from(controllers[controllerKey]!.text.split(',').map((e) => double.parse(e)));
              }
              if(controllerKey.contains('p_treatment_over_5_by_location')){
                (coverages[i] as SteadyTreatmentCoverage).pTreatmentOver5ByLocation = List<double>.from(controllers[controllerKey]!.text.split(',').map((e) => double.parse(e)));
              }
              // print('pTreatmentUnder5ByLocation: $controllerKey ${(coverages[i] as SteadyTreatmentCoverage).pTreatmentUnder5ByLocation}');
              // print('pTreatmentOver5ByLocation: $controllerKey ${(coverages[i] as SteadyTreatmentCoverage).pTreatmentOver5ByLocation}');
            }
            if(coverages[i] is LinearTreatmentCoverage){
              if(controllerKey.contains('p_treatment_under_5_by_location_to')){
                (coverages[i] as LinearTreatmentCoverage).pTreatmentUnder5ByLocationTo = List<double>.from(controllers[controllerKey]!.text.split(',').map((e) => double.parse(e)));
              }
              if(controllerKey.contains('p_treatment_over_5_by_location_to')){
                (coverages[i] as LinearTreatmentCoverage).pTreatmentOver5ByLocationTo = List<double>.from(controllers[controllerKey]!.text.split(',').map((e) => double.parse(e)));
              }
            }
            if(coverages[i] is InflatedTreatmentCoverage){
              if(controllerKey.contains('annual_inflation_rate')){
                (coverages[i] as InflatedTreatmentCoverage).annualInflationRate = double.parse(controllers[controllerKey]!.text);
              }
            }
          }
        }
      }
    }
    // print('Coverages dates after update:');
    // coverages.forEach((coverage) => print(coverage.dates));
  }
  
  @override
  ChangeTreatmentCoverageState createState() => ChangeTreatmentCoverageState();
}

class ChangeTreatmentCoverageState extends EventState<ChangeTreatmentCoverage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShadForm(
          key: widget.formKey,
          child: SizedBox(
            // width: widget.width,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for(int index = 0; index < widget.coverages.length; index++)
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Divider(),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: widget.formWidth*0.85,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(widget.coverages[index].type()),
                                    ((widget.formEditable && index == widget.coverages.length - 1))
                                        ? SizedBox(
                                      child: Column(
                                        children: [
                                          ShadButton(
                                            icon: (widget.coverages.length == 1) ? Icon(Icons.edit) : Icon(Icons.delete),
                                            onPressed: () {
                                              if(widget.coverages.length == 1){
                                                TreatmentCoverageType type = TreatmentCoverageType.values.firstWhere((element)
                                                => element.label == widget.controllers[Utils.getFormKeyID(widget.id, 'type')]!.text);
                                                showShadDialog(context: context, builder: (context){
                                                  return ShadDialog(
                                                    title: Text('Change Coverage Type'),
                                                    actions: [
                                                      ShadButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            widget.deleteEntry();
                                                            widget.addEntry();
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text('OK'),
                                                      ),
                                                    ],
                                                    child: Column(
                                                      children: [
                                                        // Text('Please select another treatment coverage type.'),
                                                        ShadRadioGroupFormField<TreatmentCoverageType>(
                                                          id: '${widget.id}#treatment_coverage_type',
                                                          initialValue: type,
                                                          axis: Axis.horizontal,
                                                          spacing: 10,
                                                          onChanged: (value) {
                                                            widget.controllers[Utils.getFormKeyID(widget.id, 'type')]!.text = value!.label;
                                                          },
                                                          items: TreatmentCoverageType.values.map(
                                                                (e) => ShadRadio(
                                                              value: e,
                                                              label: Text(e.label),
                                                            ),
                                                          ),
                                                          validator: (v) {
                                                            if (v == null) {
                                                              return 'You need to select a treatment coverage type.';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                              }
                                              else{
                                                setState(() {
                                                  widget.deleteEntry();
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ) : SizedBox(),
                                  ],
                                ),
                                if(widget.coverages[index] is SteadyTreatmentCoverage)
                                  for(int i = 0; i < (widget.coverages[index] as SteadyTreatmentCoverage).dates.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // widget.eventForm.EventDateFormField('${widget.coverages[index].id}#date', dateID: i.toString()),
                                          // widget.eventForm.EventDoubleArrayFormField('${widget.coverages[index].id}#p_treatment_under_5_by_location', lower: 0.0, upper: 1.0),
                                          // widget.eventForm.EventDoubleArrayFormField('${widget.coverages[index].id}#p_treatment_over_5_by_location', lower: 0.0, upper: 1.0),
                                          EventDetailCardForm(
                                            type: EventDetailCardFormType.date,
                                            controllerKey: '${widget.coverages[index].id}#date',
                                            editable: widget.formEditable,
                                            width: widget.formWidth*0.9*0.75,
                                            event: widget,
                                            dateID: i.toString(),
                                          ),
                                          EventDetailCardForm(
                                            type: EventDetailCardFormType.doubleArray,
                                            controllerKey: '${widget.coverages[index].id}#p_treatment_under_5_by_location',
                                            editable: widget.formEditable,
                                            width: widget.formWidth*0.9*0.75,
                                            event: widget,
                                            lower: 0.0,
                                            upper: 1.0,
                                          ),
                                          EventDetailCardForm(
                                            type: EventDetailCardFormType.doubleArray,
                                            controllerKey: '${widget.coverages[index].id}#p_treatment_over_5_by_location',
                                            editable: widget.formEditable,
                                            width: widget.formWidth*0.9*0.75,
                                            event: widget,
                                            lower: 0.0,
                                            upper: 1.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                if(widget.coverages[index] is InflatedTreatmentCoverage)
                                  for(int i = 0; i < (widget.coverages[index] as InflatedTreatmentCoverage).dates.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          // widget.eventForm.EventDateFormField('${widget.coverages[index].id}#date', dateID: i.toString()),
                                          // widget.eventForm.EventDoubleFormField('${widget.coverages[index].id}#annual_inflation_rate', lower: 0.0, upper: 1.0),
                                          EventDetailCardForm(
                                            type: EventDetailCardFormType.date,
                                            controllerKey: '${widget.coverages[index].id}#date',
                                            editable: widget.formEditable,
                                            width: widget.formWidth*0.9*0.75,
                                            event: widget,
                                            dateID: i.toString(),
                                          ),
                                          EventDetailCardForm(
                                            type: EventDetailCardFormType.double,
                                            controllerKey: '${widget.coverages[index].id}#annual_inflation_rate',
                                            editable: widget.formEditable,
                                            width: widget.formWidth*0.9*0.75,
                                            event: widget,
                                            lower: 0.0,
                                            upper: 1.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                if(widget.coverages[index] is LinearTreatmentCoverage)
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        // widget.eventForm.EventDateFormFieldCustomLabel('${widget.coverages[index].id}#date', 'date from', dateID: '0'),
                                        // widget.eventForm.EventDateFormFieldCustomLabel('${widget.coverages[index].id}#date', 'date to', dateID: '1'),
                                        // widget.eventForm.EventDoubleArrayFormField('${widget.coverages[index].id}#p_treatment_under_5_by_location_to', lower: 0.0, upper: 1.0),
                                        // widget.eventForm.EventDoubleArrayFormField('${widget.coverages[index].id}#p_treatment_over_5_by_location_to', lower: 0.0, upper: 1.0),
                                        EventDetailCardForm(
                                          type: EventDetailCardFormType.dateCustomLabel,
                                          controllerKey: '${widget.coverages[index].id}#date',
                                          editable: widget.formEditable,
                                          width: widget.formWidth*0.9*0.75,
                                          event: widget,
                                          dateID: '0',
                                          dateLabel: 'date from',
                                        ),
                                        EventDetailCardForm(
                                          type: EventDetailCardFormType.dateCustomLabel,
                                          controllerKey: '${widget.coverages[index].id}#date',
                                          editable: widget.formEditable,
                                          width: widget.formWidth*0.9*0.75,
                                          event: widget,
                                          dateID: '1',
                                          dateLabel: 'date to',
                                        ),
                                        EventDetailCardForm(
                                          type: EventDetailCardFormType.doubleArray,
                                          controllerKey: '${widget.coverages[index].id}#p_treatment_under_5_by_location_to',
                                          editable: widget.formEditable,
                                          width: widget.formWidth*0.9*0.75,
                                          event: widget,
                                          lower: 0.0,
                                          upper: 1.0,
                                        ),
                                        EventDetailCardForm(
                                          type: EventDetailCardFormType.doubleArray,
                                          controllerKey: '${widget.coverages[index].id}#p_treatment_over_5_by_location_to',
                                          editable: widget.formEditable,
                                          width: widget.formWidth*0.9*0.75,
                                          event: widget,
                                          lower: 0.0,
                                          upper: 1.0,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
        widget.formEditable ? Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Divider(),
            ShadRadioGroupFormField<TreatmentCoverageType>(
              id: '${widget.id}#treatment_coverage_type',
              label: const Text('Treatment Coverage Type'),
              initialValue: TreatmentCoverageType.SteadyTCM,
              axis: Axis.horizontal,
              onChanged: (value) {
                widget.controllers[Utils.getFormKeyID(widget.id, 'type')]!.text = value!.label;
              },
              items: TreatmentCoverageType.values.map(
                    (e) => ShadRadio(
                  value: e,
                  label: Text(e.label),
                ),
              ),
              validator: (v) {
                if (v == null) {
                  return 'You need to select a notification type.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            ShadButton(
                onPressed: () {
                  setState(() {
                    widget.addEntry();
                  });
                },
                child: Text('Add Treatment Coverage')
            ),
          ],
        ) : SizedBox(),
      ],
    );
  }
}