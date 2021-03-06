import 'package:flutter/material.dart';

import 'package:sma/helpers/color/color_helper.dart';
import 'package:sma/models/markets/sector_performance/sector_performance_model.dart';

class SectorPerformance extends StatelessWidget {

  final SectorPerformanceModel performanceData;

  SectorPerformance({
    @required this.performanceData
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      addAutomaticKeepAlives: false,
      padding: EdgeInsets.only(top: 16),
      physics: NeverScrollableScrollPhysics(),
      itemCount: performanceData.performanceModelToday.sectors.length,
      itemBuilder: (BuildContext context, int index) => _buildListTile(
        context: context,
        sectorPerformance: performanceData.performanceModelToday.sectors[index]
      )
    );
  }

  Widget _buildListTile({BuildContext context, SingleSectorPerformance sectorPerformance}) {

    final changeString = sectorPerformance.change.replaceFirst(RegExp('%'), '');
    final change = double.parse(changeString);
    final width = change > 9.99 ? null : 100.0;
    return Column(
      children: <Widget>[
        Divider(height: 2),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(sectorPerformance.name, style: Theme.of(context).textTheme.caption),
          trailing: Container(
            width: width,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(sectorPerformance.change, style: TextStyle (color: determineColorBasedOnChange(change), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ),
        )
      ],
    );
  }
}