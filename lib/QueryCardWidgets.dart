import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

Future<Widget> genderDistributionWidget(Function getData) async {
  List<Map<String, dynamic>> data = await getData();

  return charts.PieChart([
    charts.Series<Map<String, dynamic>, String>(
        id: 'Gender Distribution',
        domainFn: (Map<String, dynamic> record, _) => record['gender'],
        measureFn: (Map<String, dynamic> record, _) => record['pct'],
        data: [
          <String, dynamic>{'gender': 'male', 'pct': data[0]['male'] as double},
          <String, dynamic>{
            'gender': 'female',
            'pct': data[0]['female'] as double
          }
        ],
        labelAccessorFn: (Map<String, dynamic> record, _) =>
        record['gender'] as String)
  ],
      animate: false,
      defaultRenderer: charts.ArcRendererConfig(arcRendererDecorators: [
        charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.outside,
            outsideLabelStyleSpec: charts.TextStyleSpec(
                fontSize: 16, color: charts.Color.fromHex(code: "#FF0000")))
      ]));
}

Future<Widget> mostExperiencedManagersWidget(Function getData) async {

  List<Map<String, dynamic>> data = await getData();

  return Column(
      children: data.map((Map<String, dynamic> record) =>
          Text('${record['manager_name']}')).toList());
}

Future<Widget> avgDrawsBySpeedWidget(Function getData) async {
  List<Map<String, dynamic>> data = await getData();

  return charts.BarChart([
    charts.Series<Map<String, dynamic>, String>(

        id: 'Draws By Speed',
        domainFn: (Map<String, dynamic> record, _) => record['speed'],
        measureFn: (Map<String, dynamic> record, _) => record['avg_draws'],
        data: data,
        labelAccessorFn: (Map<String, dynamic> record, _) =>
        record['speed'] as String,

    )
  ], animate: false);
}

Future<Widget> gameStatusDistributionWidget(Function getData) async {
  List<Map<String, dynamic>> data = await getData();

  return charts.PieChart([
    charts.Series<Map<String, dynamic>, String>(
        id: 'Game Status Distribution',
        domainFn: (Map<String, dynamic> record, _) => record['status'],
        measureFn: (Map<String, dynamic> record, _) => record['status_count'],
        data: data,
        labelAccessorFn: (Map<String, dynamic> record, _) =>
        record['status'] as String)
  ],
      animate: false,
      defaultRenderer: charts.ArcRendererConfig(arcRendererDecorators: [
        charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.outside,
            outsideLabelStyleSpec: charts.TextStyleSpec(
                fontSize: 16, color: charts.Color.fromHex(code: "#FF0000")))
      ]));
}

Future<Widget> numPPlayersWidget(Function getData) async {
  List<Map<String, dynamic>> data = await getData();

  return Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.blue, width: 4.0)),
    alignment: Alignment.center,
    child: Text('${data[0]['COUNT(PLAYER_ID)']}', style: TextStyle(fontSize: 32), textAlign: TextAlign.center)
  );
}