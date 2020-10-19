import 'package:flutter/material.dart';
import 'package:db_mini_project/database.dart';

class GamesPage extends StatefulWidget {
  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final _searchBarController = TextEditingController();
  List<Map<String, dynamic>> _games = [];

  void _search() {
    DBProvider.db.getGames(text: _searchBarController.text).then((result) =>
        setState(() {
          _games = result;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Games')),
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(children: <Widget>[
            SizedBox(height: 20),
            TextField(
              controller: _searchBarController,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelText: 'Search Games'),
            ),
            SizedBox(height: 20),
            RaisedButton(
                child: Text('Search'),
                onPressed: () => _search(),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.blue)),
                color: Colors.blue,
                textColor: Colors.white),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(flex: 2, child: Text('White', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Black', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text('Winner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),

              ]
            ),
            Divider(thickness: 4),
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _games.length,
                    itemBuilder: (context, i) =>
                        GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/games/gameViewer', arguments: {
                                'game_id': _games[i]['game_id'],
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: [
                                      Expanded(flex: 2, child: Text('${_games[i]['white_player_id']}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center)),
                                      Expanded(flex: 2, child: Text('${_games[i]['black_player_id']}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center)),
                                      Expanded(flex: 1, child: Text('${_games[i]['winner']}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center)),
                                    ]
                                )
                            )
                        )
                )
            )
          ]),
        ));
  }
}
