import 'package:flutter/material.dart';
import 'package:db_mini_project/database.dart';

class ManagersPage extends StatefulWidget {
  @override
  _ManagersPageState createState() => _ManagersPageState();
}

class _ManagersPageState extends State<ManagersPage> {
  final _searchBarController = TextEditingController();
  bool _showExperiencedManagers = false;
  List<Map<String, dynamic>> _managers = [];

  void _search(String by) {
    print('show experienced managers: $_showExperiencedManagers');
    DBProvider.db.getManagersBy(text: _searchBarController.text, by: by, showExperiencedManagers: _showExperiencedManagers).then((result) =>
        setState(() {
          _managers = result;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Managers')),
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(children: <Widget>[
            SizedBox(height: 20),
            TextField(
              controller: _searchBarController,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelText: 'Search Managers'),
            ),
            SizedBox(height: 20),
            Text('Search By:', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                      child: Text('Name'),
                      onPressed: () => _search('manager_name'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white),
                  RaisedButton(
                      child: Text('Years Experience'),
                      onPressed: () => _search('years_experience'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white),
                ]),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _showExperiencedManagers,
                  onChanged: (bool value) { setState(() { _showExperiencedManagers = value; }); }
                ),
                Text('Show only experienced managers')
              ]
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                Expanded(flex: 1, child: Text('ID', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text('Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text('Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ]
            ),
            Divider(thickness: 4),
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _managers.length,
                    itemBuilder: (context, i) =>
                        GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/managers/managerViewer', arguments: {
                                'manager_id': _managers[i]['manager_id'],
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                    children: _managers[i].values.map((
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
