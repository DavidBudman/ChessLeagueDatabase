import 'package:flutter/material.dart';
import 'package:db_mini_project/QueryCard.dart';
import 'package:db_mini_project/database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PlayerViewerPage extends StatefulWidget {
  final String playerId;

  PlayerViewerPage(this.playerId);

  @override
  _PlayerViewerPageState createState() => _PlayerViewerPageState();
}

class _PlayerViewerPageState extends State<PlayerViewerPage> {
  List<QueryCard> _queryCards;
  Future _playerData;

  @override
  void initState() {
    super.initState();
    _queryCards = <QueryCard>[
      // QueryCard('Number of Games Played by Game Speed', avgTeamRatingBySpeedWidget(DBProvider.db.avgTeamRatingBySpeedQuery)),
    ];
    _playerData = DBProvider.db.getPlayerById(this.widget.playerId);

    // speedDropDownValue = 'rapid';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text('Players')),
        body: getBody(context));
  }

  Widget getBody(BuildContext context) {
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                  child: Text('${this.widget.playerId}',
                      style: TextStyle(fontSize: 32, fontFamily: 'Open Sans'))),
              SizedBox(height: 20),
              Center(
                child: getPlayerDetails()
              ),
              SizedBox(height: 20),
              getOtherPlayerDetails(),
              // getCards(context)
            ]));
  }

  Widget getPlayerDetails() {
    return FutureBuilder(
      future: _playerData,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container();
        }
        return Text('language: ${(snap.data as Map<String, dynamic>)['lang']}, team id: ${(snap.data as Map<String, dynamic>)['team_id']}',
          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)
        );
      }
    );
  }

  Widget getOtherPlayerDetails() {
    return FutureBuilder(
        future: _playerData,
        builder: (context, snap) {
          if (!snap.hasData) {
            print('no data was returned');
            return Container();
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('gender: ${(snap.data as Map<String, dynamic>)['gender']}', style: TextStyle(fontSize: 20)),
            Text('bullet games played: ${(snap.data as Map<String, dynamic>)['bullet_games']}', style: TextStyle(fontSize: 20)),
            Text('bullet rating: ${(snap.data as Map<String, dynamic>)['bullet_rating']}', style: TextStyle(fontSize: 20)),
            Text('blitz games played: ${(snap.data as Map<String, dynamic>)['blitz_games']}', style: TextStyle(fontSize: 20)),
            Text('blitz rating: ${(snap.data as Map<String, dynamic>)['blitz_rating']}', style: TextStyle(fontSize: 20)),
            Text('classical games played: ${(snap.data as Map<String, dynamic>)['classical_games']}', style: TextStyle(fontSize: 20)),
            Text('classical rating: ${(snap.data as Map<String, dynamic>)['classical_rating']}', style: TextStyle(fontSize: 20)),
            Text('rapid games played: ${(snap.data as Map<String, dynamic>)['rapid_games']}', style: TextStyle(fontSize: 20)),
            Text('rapid rating: ${(snap.data as Map<String, dynamic>)['rapid_rating']}', style: TextStyle(fontSize: 20)),

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

}
