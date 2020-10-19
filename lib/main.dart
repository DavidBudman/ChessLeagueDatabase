import 'package:flutter/material.dart';
import 'package:db_mini_project/HomePage.dart';

import 'GamesPage.dart';
import 'GameViewerPage.dart';
import 'ManagersPage.dart';
import 'ManagerViewerPage.dart';
import 'PlayersPage.dart';
import 'PlayerViewerPage.dart';
import 'TeamsPage.dart';
import 'TeamViewerPage.dart';
import 'VenuesPage.dart';
import 'VenueViewerPage.dart';
import 'VenueCounterPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Chess League',
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          var routes = <String, WidgetBuilder>{
            '/': (context) => HomePage(),
            '/games': (context) => GamesPage(),
            '/games/gameViewer': (context) => GameViewerPage(
                (settings.arguments as Map<String, dynamic>)['game_id']
            ),
            '/managers': (context) => ManagersPage(),
            '/managers/managerViewer': (context) => ManagerViewerPage(
                (settings.arguments as Map<String, dynamic>)['manager_id']
            ),
            '/players': (context) => PlayersPage(),
            '/players/playerViewer': (context) => PlayerViewerPage(
                  (settings.arguments as Map<String, dynamic>)['player_id']
              ),
            '/teams': (context) => TeamsPage(),
            '/teams/teamViewer': (context) => TeamViewerPage(
                (settings.arguments as Map<String, dynamic>)['team_id']
            ),
            '/venues': (context) => VenuesPage(),
            '/venues/venueViewer': (context) => VenueViewerPage(
                (settings.arguments as Map<String, dynamic>)['venue_id'],
                (settings.arguments as Map<String, dynamic>)['venue_name']),
            '/venue_counter': (context) => VenueCounterPage()
          };
          WidgetBuilder builder = routes[settings.name];
          return MaterialPageRoute(builder: (context) => builder(context));
        }

    );
  }
}