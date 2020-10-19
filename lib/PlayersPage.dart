import 'package:flutter/material.dart';
import 'package:db_mini_project/database.dart';

class PlayersPage extends StatefulWidget {
  @override
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final _searchBarController = TextEditingController();
  List<Map<String, dynamic>> _players = [];

  void _search(String by) {
    DBProvider.db.getPlayersBy(text: _searchBarController.text, by: by).then((result) =>
        setState(() {
          _players = result;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Players')),
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(children: <Widget>[
            SizedBox(height: 20),
            TextField(
              controller: _searchBarController,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelText: 'Search Players'),
            ),
            SizedBox(height: 20),
            Text('Search By:', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                      child: Text('ID'),
                      onPressed: () => _search('player_id'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white),
                  RaisedButton(
                      child: Text('Language'),
                      onPressed: () => _search('lang'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white),
                  RaisedButton(
                      child: Text('Team ID'),
                      onPressed: () => _search('team_id'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white)
                ]),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(flex: 2, child: Text('ID', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('Team', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                ]
            ),
            Divider(thickness: 4),
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _players.length,
                    itemBuilder: (context, i) =>
                        GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/players/playerViewer', arguments: {
                                'player_id': _players[i]['player_id'],
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: <Widget>[
                                      Expanded(flex: 2, child: Text('${_players[i]['player_id']}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center)),
                                      Expanded(flex: 1, child: Text('${_players[i]['lang']}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center)),
                                      Expanded(flex: 1, child: Text('${_players[i]['team_id']}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center)),
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
