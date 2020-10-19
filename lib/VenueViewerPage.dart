import 'package:flutter/material.dart';
import 'package:db_mini_project/QueryCard.dart';
import 'package:db_mini_project/database.dart';

class VenueViewerPage extends StatefulWidget {
  final int venueId;
  final String venueName;

  VenueViewerPage(this.venueId, this.venueName);

  @override
  _VenueViewerPageState createState() => _VenueViewerPageState();
}

class _VenueViewerPageState extends State<VenueViewerPage> {
  List<QueryCard> _queryCards;

  @override
  void initState() {
    super.initState();
    _queryCards = <QueryCard>[
      QueryCard('Number of Games Played in Venue', numGamesPlayedInVenueWidget(DBProvider.db.numGamesPlayedInVenueQuery)),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text('Venues')),
        body: getBody(context));
  }

  Widget getBody(BuildContext context) {
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                  child: Text('${this.widget.venueName}',
                      style: TextStyle(fontSize: 32, fontFamily: 'Open Sans'))),
              SizedBox(height: 20),
              Center(
                child: getLocation()
              ),
              SizedBox(height: 20),
              getCards(context)
            ]));
  }

  Widget getLocation() {
    return FutureBuilder(
      future: DBProvider.db.getVenueById(this.widget.venueId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container();
        }
        Map<String, dynamic> data = snap.data;
        return Text('ID: ${data['venue_id']}, ${data['city']}, ${data['country']}',
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

  Future<Widget> numGamesPlayedInVenueWidget(Function(int) getData) async {

    Map<String, dynamic> data = await getData(this.widget.venueId);

    return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 4.0)),
        alignment: Alignment.center,
        child: Text('${data['count(venue_id)']}', style: TextStyle(fontSize: 32), textAlign: TextAlign.center)
    );
  }

}
