import 'package:flutter/material.dart';
import 'package:db_mini_project/QueryCard.dart';
import 'package:db_mini_project/database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GameViewerPage extends StatefulWidget {
  final String gameId;

  GameViewerPage(this.gameId);

  @override
  _GameViewerPageState createState() => _GameViewerPageState();
}

class _GameViewerPageState extends State<GameViewerPage> {
  List<QueryCard> _queryCards;

  @override
  void initState() {
    super.initState();
    _queryCards = <QueryCard>[
      //QueryCard('Number of Games Played in Game', avgTeamRatingBySpeedWidget(avgTeamRatingBySpeedQuery)),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text('Games')),
        body: getBody(context));
  }

  Widget getBody(BuildContext context) {
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                  child: Text('${this.widget.gameId}',
                      style: TextStyle(fontSize: 32, fontFamily: 'Open Sans'))),
              SizedBox(height: 20),
              getGameDetails(),
              SizedBox(height: 20),
              getCards(context)
            ]));
  }

  Widget getGameDetails() {
    print('running getGameDetails');
    return FutureBuilder(
      future: DBProvider.db.getGameById(this.widget.gameId),
      builder: (context, snap) {
        if (!snap.hasData) {
          print('no data was returned');
          return Container();
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('game id: ${(snap.data as Map<String, dynamic>)['game_id']}', style: TextStyle(fontSize: 20)),
          Text('white id: ${(snap.data as Map<String, dynamic>)['white_player_id']}', style: TextStyle(fontSize: 20)),
          Text('black id: ${(snap.data as Map<String, dynamic>)['black_player_id']}', style: TextStyle(fontSize: 20)),
          Text('winner: ${(snap.data as Map<String, dynamic>)['winner']}', style: TextStyle(fontSize: 20)),
          Text('status: ${(snap.data as Map<String, dynamic>)['status']}', style: TextStyle(fontSize: 20)),
          Text('opening name: ${(snap.data as Map<String, dynamic>)['opening_name']}', style: TextStyle(fontSize: 20)),
          Text('venue id: ${(snap.data as Map<String, dynamic>)['venue_id']}', style: TextStyle(fontSize: 20)),
          Text('time control: ${(snap.data as Map<String, dynamic>)['time_duration']}+${(snap.data as Map<String, dynamic>)['time_increment']}', style: TextStyle(fontSize: 20)),
        ]);
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

  Future<Widget> avgTeamRatingBySpeedWidget(Function(String) getData) async {

    List<Map<String, dynamic>> data = await getData(this.widget.gameId);

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

}
