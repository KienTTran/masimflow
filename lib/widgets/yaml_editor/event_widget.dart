import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masimflow/providers/data_providers.dart';
import 'package:masimflow/widgets/yaml_editor/event_detail_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/events/event.dart';
import '../../utils/utils.dart';

class EventCard extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final Event event;

  const EventCard({
    Key? key,
    required this.width,
    required this.height,
    required this.event,
  }) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  @override
  Widget build(BuildContext context) {
    return ShadCard(
      width: widget.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: widget.width,
              child:
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.event.name.toString().split('_').join(' '),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  _buildEventActionButtons(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ShadAccordion<Event>(
                children: [
                  ShadAccordionItem(
                    title: Text('Properties'),
                    value: widget.event,
                    separator: null,
                    child: EventDetailCard(
                      eventID: widget.event.id,
                      width: widget.width,
                        height: widget.height,
                      editable: false,
                      popBack: (){}
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ShadButton.outline(
          onPressed: () {
            if (ref.read(configYamlFileProvider.notifier).getMutYamlMap().isEmpty) {
              showShadDialog(
                  context: context,
                  builder: (context) {
                    return ShadDialog.alert(
                      title: Text('Error'),
                      description: Text('Please load a yaml file first'),
                      actions: [
                        ShadButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  }
              );
            }
            else {
              showShadSheet(
                  context: context,
                  side: ShadSheetSide.right,
                  builder: (context) {
                    return ShadSheet(
                      constraints: const BoxConstraints(maxWidth: 512),
                      // title: Text(widget.event.name.replaceAll('_', ' ')),
                      title: Text(widget.event.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Material(
                                  child:
                                    EventDetailCard(
                                        eventID: widget.event.id,
                                        width: 512,
                                        height: widget.height,
                                        editable: true,
                                        popBack: () => Navigator.of(context).pop())
                                  )
                            ]
                        ),
                      ),
                      // actions: [
                      // ],
                    );
                  }
              );
            }
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}


// Widget _buildEventDetails(Event event) {
//     var startingDate = ref.read(dateMapProvider.notifier).get()['starting_date'];
//     var endingDate = ref.read(dateMapProvider.notifier).get()['ending_date'];
//
//     startingDate ??= DateTime.now();
//     endingDate ??= DateTime.now();
//
//     if (event is ChangeWithinHostInducedRecombination) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//           Text("Value: ${event.value}"),
//         ],
//       );
//     } else if (event is ChangeMutationProbabilityPerLocus) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final strategy in event.entries)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                 Text("Mutation Probability Per Locus: ${strategy.mutationProbabilityPerLocus}"),
//                 const Divider(),
//               ],
//             ),
//         ],
//       );
//     } else if (event is TurnOffMutation) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final date in event.dates)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                 const Divider(),
//               ],
//             ),
//         ],
//       );
//     } else if (event is TurnOnMutation) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final date in event.dates)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                 const Divider(),
//               ],
//             ),
//         ],
//       );
//     } else if (event is ChangeTreatmentCoverage) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Event: ${event.name}"),
//           const SizedBox(height: 8),
//           // For each TreatmentCoverage, display its details.
//           ...event.coverages.map((coverage) {
//             if (coverage is SteadyTreatmentCoverage) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Type: SteadyTCM"),
//                   Text("Date: ${Utils.getRandomDateInRange(startingDate!, endingDate!, 'yyyy/MM/dd')}"),
//                   Text("Treatment under 5: ${coverage.pTreatmentUnder5ByLocation.join(', ')}"),
//                   Text("Treatment over 5: ${coverage.pTreatmentOver5ByLocation.join(', ')}"),
//                   const Divider(),
//                 ],
//               );
//             } else if (coverage is InflatedTreatmentCoverage) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Type: InflatedTCM"),
//                   Text("Date: ${Utils.getRandomDateInRange(startingDate!, endingDate!, 'yyyy/MM/dd')}"),
//                   Text("Annual Inflation Rate: ${coverage.annualInflationRate}"),
//                   const Divider(),
//                 ],
//               );
//             } else if (coverage is LinearTreatmentCoverage) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Type: LinearTCM"),
//                   Text("From Date: ${Utils.getRandomDateInRange(startingDate!, endingDate!, 'yyyy/MM/dd')}"),
//                   Text("To Date: ${Utils.getRandomDateInRange(startingDate!, endingDate!, 'yyyy/MM/dd')}"),
//                   Text("Treatment under 5 (target): ${coverage.pTreatmentUnder5ByLocationTo.join(', ')}"),
//                   Text("Treatment over 5 (target): ${coverage.pTreatmentOver5ByLocationTo.join(', ')}"),
//                   const Divider(),
//                 ],
//               );
//             } else {
//               return Container();
//             }
//           }).toList(),
//         ],
//       )
//       ;
//     } else if (event is ChangeTreatmentStrategy) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final strategy in event.changes)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                 Text("Strategy ID: ${strategy.strategyId}"),
//                 const Divider(),
//               ],
//             ),
//         ],
//       );
//     } else if (event is ModifyNestedMftStrategy) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final mda in event.entries)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                 Text("Strategy ID: ${mda.strategyId}"),
//                 const Divider(),
//               ],
//             ),
//         ],
//       );
//     } else if (event is SingleRoundMDA) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final mda in event.treatments)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                 Text("Days to Complete All Treatments: ${mda.daysToCompleteAllTreatments}"),
//                 Text("Fraction Population Targeted: ${mda.fractionPopulationTargeted}"),
//                 const Divider(),
//               ],
//             ),
//         ],
//       );
//     } else if (event is IntroduceParasites) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final location in event.locations)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Location: ${location.location}"),
//                 for(final parasite in location.parasiteInfo)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("\t\tDate: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                       Text("\t\tGenotype:\n\t\t${parasite.genotypeAASequence}"),
//                       Text("\t\tNumber of cases: ${parasite.numberOfCases}"),
//                       const Divider(),
//                     ],
//                   ),
//                 ]
//             ),
//         ],
//       );
//     } else if (event is IntroduceParasitesPeriodically) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final location in event.locations)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Location: ${location.location}"),
//                 for(final parasite in location.parasiteInfo)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("\t\tStart Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                       Text("\t\tDuration: ${parasite.duration}"),
//                       Text("\t\tGenotype:\n\t\t${parasite.genotypeAASequence}"),
//                       Text("\t\tNumber of cases: ${parasite.numberOfCases}"),
//                       const Divider(),
//                     ],
//                   ),
//                 ]
//             ),
//         ],
//       );
//     } else if (event is Introduce580YParasites) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final location in event.entries)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Location: ${location.location}"),
//                 Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                 Text("Fraction: ${location.fraction}"),
//                 const Divider(),
//                 ]
//             ),
//         ],
//       );
//     } else if (event is IntroduceAQMutantParasites) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final location in event.entries)
//             Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Location: ${location.location}"),
//                   Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                   Text("Fraction: ${location.fraction}"),
//                   const Divider(),
//                 ]
//             ),
//         ],
//       );
//     } else if (event is IntroduceLumefantrineMutantParasites ) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final location in event.entries)
//             Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Location: ${location.location}"),
//                   Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                   Text("Fraction: ${location.fraction}"),
//                   const Divider(),
//                 ]
//             ),
//         ],
//       );
//     } else if (event is IntroduceTripleMutantToDpmParasites) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final location in event.entries)
//             Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Location: ${location.location}"),
//                   Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                   Text("Fraction: ${location.fraction}"),
//                   const Divider(),
//                 ]
//             ),
//         ],
//       );
//     } else if (event is IntroducePlas2Parasites) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final location in event.entries)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Location: ${location.location}"),
//                 Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                 Text("Fraction: ${location.fraction}"),
//                 const Divider(),
//                 ],
//             ),
//         ],
//       );
//     } else if (event is ChangeInterruptedFeedingRate) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           for(final location in event.entries)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Location: ${location.location}"),
//                 Text("Date: ${Utils.getRandomDateInRange(startingDate, endingDate, 'yyyy/MM/dd')}"),
//                 Text("Interrupted Feeding Rate: ${location.interruptedFeedingRate}"),
//                 const Divider(),
//               ],
//             ),
//         ],
//       );
//     } else {
//       return Text("Unknown event type");
//     }
//   }
// }
