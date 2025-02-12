import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/models/markers/strategy_marker.dart';
import 'package:masimflow/providers/ui_providers.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../models/events/event.dart';
import '../../models/markers/event_marker.dart';
import '../../providers/data_providers.dart';
import '../../utils/form_validator.dart';
import '../../utils/utils.dart';
import 'event_detail_card_form.dart';

class EventDetailCard extends ConsumerStatefulWidget {
  final String eventID;
  final double width;
  final double height;
  final bool editable;
  final bool isUpdate;
  final VoidCallback popBack;

  const EventDetailCard({
    super.key,
    required this.eventID,
    required this.width,
    required this.height,
    required this.popBack,
    this.editable = false,
    this.isUpdate = false,
  });

  @override
  _EventDetailCardState createState() => _EventDetailCardState();
}

/// This widget wraps the _builddefaultEventDetails function. It accepts an event and a flag [editable].
class _EventDetailCardState extends ConsumerState<EventDetailCard> {
  final GlobalKey<ShadFormState> formKey = GlobalKey<ShadFormState>();
  DateTime randomDate = DateTime.now();
  late Event defaultEventDetail;

  @override
  void initState() {
    super.initState();
    if(widget.isUpdate){
      defaultEventDetail = ref.read(eventDisplayMapProvider.notifier).getEvent(widget.eventID)!;
    }
    else{
      defaultEventDetail = ref.read(eventTemplateMapProvider.notifier).get()[widget.eventID]!;
    }
    defaultEventDetail.formKey = formKey;
  }

  @override
  Widget build(BuildContext context) {
    // print('EventDetailCard build: ${widget.eventID}');
    return SizedBox(
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildEventDetails(defaultEventDetail, editable: widget.editable),
            const SizedBox(height: 32),
            widget.editable ? SizedBox(
              width: widget.width*0.85,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.isUpdate ? ShadButton(
                      onPressed: () {

                        if(formKey.currentState!.validate(focusOnInvalid: true)){
                          // print('valid');
                        }
                        else{
                          // print('invalid');
                          return;
                        }

                        final startingDate  = ref.read(dateMapProvider.notifier).get()['starting_date'];
                        final endingDate  = ref.read(dateMapProvider.notifier).get()['ending_date'];

                        defaultEventDetail.update();

                        // print('EventDetailCard Add: ${defaultEventDetail.dates()}');

                        if(defaultEventDetail.dates().isEmpty){
                          showShadDialog(context: context, builder: (context){
                            return ShadDialog(
                              title: Text('Error'),
                              child: Text('Please add at least one date/entry for event.'),
                              actions: [
                                ShadButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          });
                          return;
                        }
                        for(final date in defaultEventDetail.dates()){
                          if(!FormUtil.checkValidDate(context, date, startingDate!, endingDate!)){
                            return;
                          }
                        }
                        if(formKey.currentState!.saveAndValidate()){
                          var eventMarkerList = ref.read(eventMarkerListProvider.notifier).get();
                          for(var i = 0; i < eventMarkerList.length; i++){
                            if(eventMarkerList[i].event.id == defaultEventDetail.id){
                              eventMarkerList[i].event = defaultEventDetail;
                              eventMarkerList[i].setDates(defaultEventDetail.dates());
                              if(eventMarkerList[i].event.name.contains('strategy')){
                                List<DateTime> dates = eventMarkerList[i].event.dates();
                                List<dynamic> strategyIds = eventMarkerList[i].event.valuesByKey('strategy_id');
                                StrategyMarker newStrategyMarker = eventMarkerList[i].strategyMarker.copy();
                                newStrategyMarker.strategyIdDateXMapList.clear();
                                for(var i = 0; i < dates.length; i++){
                                  newStrategyMarker.strategyIdDateXMapList.add((dates[i],int.parse(strategyIds[i]),0));
                                }
                                newStrategyMarker.updateX();
                                eventMarkerList[i].strategyMarker = newStrategyMarker;
                              }
                              break;
                            }
                          }
                          ref.read(eventDisplayMapProvider.notifier).setEvent(defaultEventDetail.id, defaultEventDetail);
                          ref.read(eventMarkerListProvider.notifier).set(eventMarkerList);
                          ref.read(updateUIProvider.notifier).set(true);
                          setState(() { });
                          widget.popBack();
                        }
                      },
                      child: Text('Save changes')
                  ) : ShadButton(
                      onPressed: () {

                        if(formKey.currentState!.validate(focusOnInvalid: true)){
                          // print('valid');
                        }
                        else{
                          // print('invalid');
                          return;
                        }

                        final startingDate  = ref.read(dateMapProvider.notifier).get()['starting_date'];
                        final endingDate  = ref.read(dateMapProvider.notifier).get()['ending_date'];

                        defaultEventDetail.update();

                        // print('EventDetailCard Add: ${defaultEventDetail.dates()}');

                        if(defaultEventDetail.dates().isEmpty){
                          showShadDialog(context: context, builder: (context){
                            return ShadDialog(
                              title: Text('Error'),
                              child: Text('Please add at least one date/entry for event.'),
                              actions: [
                                ShadButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          });
                          return;
                        }

                        for(final date in defaultEventDetail.dates()){
                          // print('Add date: $date');
                          if(!FormUtil.checkValidDate(context, date, startingDate!, endingDate!)){
                            return;
                          }
                        }
                        if(formKey.currentState!.saveAndValidate()){

                          // for(var event in ref.read(eventDisplayMapProvider.notifier).get().values){
                          //   print('added event ${event.id} ${event.controllers.keys} ${event.controllers.values} ${event.dates}');
                          // }

                          Event newEvent = defaultEventDetail.copy();
                          EventMarker newEventMarker = EventMarker(
                              newEvent,
                              startingDate!,endingDate!,
                              -1,
                              10,
                              -500,
                              false
                          );
                          StrategyMarker newStrategyMarker = ref.read(strategyMarkerListProvider.notifier).get().first.copy();
                          newStrategyMarker.strategyIdDateXMapList.clear();
                          if(newEvent.name.contains('strategy')){
                            List<DateTime> dates = newEvent.dates();
                            List<dynamic> strategyIds = newEvent.valuesByKey('strategy_id');
                            for(var i = 0; i < dates.length; i++){
                              newStrategyMarker.strategyIdDateXMapList.add((dates[i],int.parse(strategyIds[i]),0));
                            }
                            newStrategyMarker.updateX();
                          }
                          newEventMarker.strategyMarker = newStrategyMarker;

                          ref.read(eventDisplayMapProvider.notifier).setEvent(newEvent.id,newEvent);
                          ref.read(eventMarkerListProvider.notifier).add(newEventMarker);
                          ref.read(updateUIProvider.notifier).set(true);

                          // for(var event in ref.read(eventDisplayMapProvider.notifier).get().values){
                          //   print('all event ${event.id} ${event.controllers.keys} ${event.controllers.values} ${event.dates}');
                          // }

                          widget.popBack();
                        }
                      },
                      child: Text('Add event')
                  ),
                  widget.isUpdate ?
                  ShadButton.destructive(
                      onPressed: () {
                        //Delete event
                        // print('Delete event ${defaultEventDetail.id}');
                        ref.read(eventMarkerListProvider.notifier).deleteEventID(defaultEventDetail.id);
                        ref.read(eventDisplayMapProvider.notifier).deleteEventID(defaultEventDetail.id);
                        ref.read(updateUIProvider.notifier).set(true);
                        setState(() {
                        });
                        widget.popBack();
                      },
                      child: Text('Delete')
                  ) : SizedBox(),
                  ShadButton(
                      onPressed: () {
                        widget.popBack();
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

  /// The modified _builddefaultEventDetails function with the extra parameter [editable].
  Widget buildEventDetails(Event event, {bool editable = false}) {
    // Access the starting and ending dates from your provider (adjust as needed)
    var startingDate = ref.read(dateMapProvider.notifier).get()['starting_date'];
    var endingDate = ref.read(dateMapProvider.notifier).get()['ending_date'];

    startingDate ??= DateTime.now();
    endingDate ??= DateTime.now();

    event.eventForm = EventDetailCardForm(context, event, editable, widget.width);

    return Column(
      children: [event],
    );
  }
}

