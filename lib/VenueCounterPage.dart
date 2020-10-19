import 'package:flutter/material.dart';
import 'package:db_mini_project/QueryCard.dart';
import 'package:db_mini_project/database.dart';

class VenueCounterPage extends StatefulWidget {
  @override
  _VenueCounterPageState createState() => _VenueCounterPageState();
}

class _VenueCounterPageState extends State<VenueCounterPage> {
  int _venue_count;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Venue Counter')),
        body: getBody(context));
  }

  @override
  void initState() {
    super.initState();
    DBProvider.db.getVenueInsertCount().then(
            (result) {
              setState(() {_venue_count = result; });
            });
  }

  Widget getBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 40),
        Center(
          child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 4.0)),
              alignment: Alignment.center,
              child: Text('$_venue_count', style: TextStyle(fontSize: 32), textAlign: TextAlign.center)),
        ),
        SizedBox(height: 20),
        RaisedButton(
          child: Text("Add Venues"),
          onPressed: () { DBProvider.db.insertVenues().then((result) => setState(() => {_venue_count = result})); }
        )
      ]
    );
  }
}
