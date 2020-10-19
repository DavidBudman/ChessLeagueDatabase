import 'package:flutter/material.dart';
import 'package:db_mini_project/database.dart';

class VenuesPage extends StatefulWidget {
  @override
  _VenuesPageState createState() => _VenuesPageState();
}

class _VenuesPageState extends State<VenuesPage> {
  final _searchBarController = TextEditingController();
  List<Map<String, dynamic>> _venues = [];
  String _buttonState = 'venue_name';

  void _search(String by) {
    setState(() => { _buttonState = by });
    DBProvider.db.getVenuesBy(text: _searchBarController.text, by: by).then((result) =>
        setState(() {
          _venues = result;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Venues')),
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(children: <Widget>[
            SizedBox(height: 20),
            TextField(
              controller: _searchBarController,
              decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelText: 'Search Venues'),
            ),
            SizedBox(height: 20),
            Text('Search By:', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                      child: Text('Name'),
                      onPressed: () => _search('venue_name'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white),
                  FlatButton(
                      child: Text('Country'),
                      onPressed: () => _search('country'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white),
                  FlatButton(
                      child: Text('City'),
                      onPressed: () => _search('city'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.blue,
                      textColor: Colors.white)
                ]),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: getTitles()
            ),
            Divider(thickness: 4),
            Expanded(
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _venues.length,
                    itemBuilder: (context, i) =>
                        GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/venues/venueViewer', arguments: {
                                'venue_id': _venues[i]['venue_id'],
                                'venue_name': _venues[i]['venue_name']
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center,
                                      children: _venues[i].values.skip(1).map((
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
  List<Widget> getTitles() {
    List<Widget> result = <Widget>[
      Expanded(flex: 3, child: Text('Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
    ];
    switch (_buttonState) {
      case 'country':
        result.add(Expanded(flex: 3, child: Text('Country', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)));
        break;
      case 'city':
        result.add(Expanded(flex: 3, child: Text('City', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)));
        break;
    }

    return result;
  }
}
