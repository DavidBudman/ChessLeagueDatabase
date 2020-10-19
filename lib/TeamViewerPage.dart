import 'package:flutter/material.dart';
import 'package:db_mini_project/QueryCard.dart';
import 'package:db_mini_project/database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class TeamViewerPage extends StatefulWidget {
  final int teamId;

  TeamViewerPage(this.teamId);

  @override
  _TeamViewerPageState createState() => _TeamViewerPageState();
}

class _TeamViewerPageState extends State<TeamViewerPage> {
  List<QueryCard> _queryCards;
  String speedDropDownValue = 'rapid';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _queryCards = <QueryCard>[
      QueryCard('Average Rating by Game Speed', avgTeamRatingBySpeedWidget(DBProvider.db.avgTeamRatingBySpeedQuery)),
    ];

    return Scaffold(
        appBar: AppBar(title: Text('Teams')),
        body: getBody(context));
  }

  Widget getBody(BuildContext context) {
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                  child: Text('Team ${this.widget.teamId}',
                      style: TextStyle(fontSize: 32, fontFamily: 'Open Sans'))),
              SizedBox(height: 20),
              Center(
                child: getTeamDetails()
              ),
              SizedBox(height: 20),
              getCards(context)
            ]));
  }

  Widget getTeamDetails() {
    return FutureBuilder(
      future: DBProvider.db.getTeamById(this.widget.teamId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container();
        }
        return Text('Manager ID: ${(snap.data as Map<String, dynamic>)['manager_id']}',
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

  Future<Widget> avgTeamRatingBySpeedWidget(Function(int, String) getData) async {
    Map<String, dynamic> data = await getData(this.widget.teamId, speedDropDownValue);
    // print('we got here and data is double?: ${data['rating'].floor()}');
    return Column(
        children: <Widget>[
          DropdownButton<String>(
            value: speedDropDownValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() { speedDropDownValue = newValue; });
            },
            items: <String>['bullet', 'blitz', 'rapid', 'classical'].map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value)
            )).toList(),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 4.0)),
            alignment: Alignment.center,
            child: Text('${data['rating'].floor()}', style: TextStyle(fontSize: 32), textAlign: TextAlign.center)
          )
        ]
    );
  }
}
