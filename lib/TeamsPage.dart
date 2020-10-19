import 'package:flutter/material.dart';
import 'package:db_mini_project/database.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final _searchBarController = TextEditingController();
  List<Map<String, dynamic>> _teams = [];

  void _search(String by) {
    DBProvider.db.getTeamsBy(text: _searchBarController.text, by: by).then((result) =>
        setState(() {
          _teams = result;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Teams')),
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(children: <Widget>[
            SizedBox(height: 20),
            TextField(
              controller: _searchBarController,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelText: 'Search Teams'),
            ),
            SizedBox(height: 20),
            Text('Search By:', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                      child: Text('Team ID'),
                      onPressed: () => _search('team_id'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white),
                  RaisedButton(
                      child: Text('Manager ID'),
                      onPressed: () => _search('manager_id'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white),
                ]),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(flex: 1, child: Text('ID', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('Manager ID', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                ]
            ),
            Divider(thickness: 4),
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _teams.length,
                    itemBuilder: (context, i) =>
                        GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/teams/teamViewer', arguments: {
                                'team_id': _teams[i]['team_id'],
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: _teams[i].values.map((
                                        dynamic value) =>
                                        Expanded(child: Text('$value', style: TextStyle(fontSize: 16), textAlign: TextAlign.center)))
                                        .toList()
                                )
                            )
                        )
                )
            )
          ]),
        ));
  }
}
