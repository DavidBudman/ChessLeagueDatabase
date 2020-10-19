// import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:db_mini_project/QueryCard.dart';
import 'package:db_mini_project/database.dart';
import 'package:db_mini_project/QueryCardWidgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<QueryCard> _queryCards;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _queryCards = <QueryCard>[
      QueryCard('Gender Distribution', genderDistributionWidget(DBProvider.db.genderDistributionQuery)),
      QueryCard('Most Experienced Managers', mostExperiencedManagersWidget(DBProvider.db.mostExperiencedManagersQuery)),
      QueryCard('Average Draws by Speed', avgDrawsBySpeedWidget(DBProvider.db.avgDrawsBySpeedQuery)),
      QueryCard('Game Status Distribution', gameStatusDistributionWidget(DBProvider.db.gameStatusDistributionQuery)),
      QueryCard('Number of players that start with \'P\'', numPPlayersWidget(DBProvider.db.numPPlayersQuery)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Chess League')),
        drawer: getDrawer(context),
        body: getBody(context));
  }

  Widget getBody(BuildContext context) {
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Center(
                  child: Text('Common Queries',
                      style: TextStyle(fontSize: 32, fontFamily: 'Open Sans'))),
              SizedBox(height: 20),
              getCards(context)
            ]));
  }

  // USING FLIP CARDS
  // Widget getCards(BuildContext context) {
  //   return Expanded(
  //     child: ListView.builder(
  //         itemCount: _queryCards.length,
  //         itemBuilder: (context, index) {
  //           return FutureBuilder(
  //               builder: (context, snap) {
  //                 if (!snap.hasData) {
  //                   return Container(
  //                     padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
  //                     // decoration: BoxDecoration(border: )
  //                     child: Container(
  //                         height: 220,
  //                         child: Center(
  //                             child: Text(_queryCards[index].title,
  //                                 style: TextStyle(fontSize: 32)))),
  //                   );
  //                 }
  //                 return Container(
  //                     padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
  //                     child: FlipCard(
  //                       direction: FlipDirection.HORIZONTAL,
  //                       front: Container(
  //                           height: 220,
  //                           child: Center(
  //                               child: Text(_queryCards[index].title,
  //                                   style: TextStyle(fontSize: 32)))),
  //                       back: Container(height: 220, color: Colors.blue, child: snap.data),
  //                     ));
  //               },
  //               future: _queryCards[index].widgetFuture);
  //         }),
  //   );
  // }

  // WITHOUT FLIP CARDS
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

  Drawer getDrawer(BuildContext context) {
    return Drawer(
        child: ListView(children: <Widget>[
          ListTile(
              title: Text('Teams'),
              leading: Icon(Icons.group),
              onTap: () {
                Navigator.pushNamed(context, '/teams');
              }),
          ListTile(
              title: Text('Games'),
              leading: Icon(MdiIcons.chessPawn),
              onTap: () {
                Navigator.pushNamed(context, '/games');
              }),
          ListTile(
              title: Text('Players'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.pushNamed(context, '/players');
              }),
          ListTile(
              title: Text('Venues'),
              leading: Icon(Icons.location_city),
              onTap: () {
                Navigator.pushNamed(context, '/venues');
              }),
          ListTile(
              title: Text('Managers'),
              leading: Icon(MdiIcons.accountHardHat),
              onTap: () {
                Navigator.pushNamed(context, '/managers');
              }),
          ListTile(
            title: Text('Venues Counter'),
            leading: Icon(Icons.equalizer),
            onTap: () {
              Navigator.pushNamed(context, '/venue_counter');
            }
          )
        ]));
  }
}
