import 'package:flutter/material.dart';
import 'package:db_mini_project/QueryCard.dart';
import 'package:db_mini_project/database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ManagerViewerPage extends StatefulWidget {
  final int managerId;

  ManagerViewerPage(this.managerId);

  @override
  _ManagerViewerPageState createState() => _ManagerViewerPageState();
}

class _ManagerViewerPageState extends State<ManagerViewerPage> {
  List<QueryCard> _queryCards;

  @override
  void initState() {
    super.initState();
    _queryCards = <QueryCard>[
      //QueryCard('Number of Games Played in Manager', avgTeamRatingBySpeedWidget(avgTeamRatingBySpeedQuery)),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text('Managers')),
        body: getBody(context));
  }

  Widget getBody(BuildContext context) {
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                  child: Text('${this.widget.managerId}',
                      style: TextStyle(fontSize: 32, fontFamily: 'Open Sans'))),
              SizedBox(height: 20),
              Center(
                child: getManagerDetails()
              ),
              SizedBox(height: 20),
              // getCards(context)
              getPlayers()
            ]));
  }

  Widget getManagerDetails() {
    return FutureBuilder(
      future: DBProvider.db.getManagerById(this.widget.managerId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container();
        }
        return Text('name: ${(snap.data as Map<String, dynamic>)['manager_name']}, years experience: ${(snap.data as Map<String, dynamic>)['years_experience']}',
          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)
        );
      }
    );
  }

  Widget getCards(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: _queryCards.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Card(
                      child: Container(
                          padding: EdgeInsets.all(20),
                          height: 220,
                          child: Center(
                              child: Text(_queryCards[index].title,
                                  style: TextStyle(fontSize: 32), textAlign: TextAlign.center))),
                    );
                  }
                  return Card(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(children: <Widget>[
                          Text(_queryCards[index].title, style: TextStyle(fontSize: 20)),
                          SizedBox(height: 20),
                          Container(height: 200, child: snap.data)
                        ])),
                  );
                },
                future: _queryCards[index].widgetFuture);
          }),
    );
  }

  Future<Widget> avgTeamRatingBySpeedWidget(Function(int) getData) async {
    List<Map<String, dynamic>> data = await getData(this.widget.managerId);

    return charts.BarChart([
      charts.Series<Map<String, dynamic>, String>(
          id: 'Rating Averages by Speed',
          domainFn: (Map<String, dynamic> record, _) => record['speed'] as String,
          measureFn: (Map<String, dynamic> record, _) => record['rating'] as double,
          data: data,
          labelAccessorFn: (Map<String, dynamic> record, _) =>
          record['GAME_TYPE'] as String)
    ], animate: false);
  }

  Widget getPlayers() {
    return FutureBuilder(
      future: DBProvider.db.getPlayersByManager(this.widget.managerId),
      builder: (context, snapshot) {
        print('data: ${snapshot.data}');
        if (!snapshot.hasData || snapshot.data == null) {
          return Container();
        }
        List<Map<String, dynamic>> data = snapshot.data;
        return Expanded(child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return Text('${data[index]['player_id']}', style: TextStyle(fontSize: 16));
          },
        ));
      });
  }

}
