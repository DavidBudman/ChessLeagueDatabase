import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {

    // uncomment following line to reset database on startup
    await deleteDatabase(join(await getDatabasesPath(), 'data.db'));
    return await openDatabase(join(await getDatabasesPath(), 'data.db'),
        onCreate: (db, version) async {
      print('running onCreate function');
      Batch batch = db.batch();
      batch.execute('''
        create table managers(
        manager_id integer not null primary key,
        manager_name varchar2(20) not null,
        years_experience integer not null);
      ''');
      batch.execute('''
        create table teams(
        team_id integer not null primary key,
        manager_id integer not null,
        constraint fk_teams foreign key (manager_id) references managers(manager_id) on delete cascade);
      ''');
      batch.execute('''
        create table venues(
        venue_id integer not null primary key,
        venue_name varchar2(40) not null,
        country varchar2(20) not null,
        city varchar2(20) not null,
        constraint positive_id check(venue_id > 0));
      ''');

      batch.execute('''
        create table TimeControls(
        time_duration integer not null,
        time_increment integer not null,
        speed varchar2(20) not null,
        constraint pk_TimeControls primary key (time_duration, time_increment));
      ''');

      batch.execute('''
        create table players(
        player_id varchar2(20) not null primary key,
        gender varchar2(20) not null,
        blitz_games number(38) not null,
        blitz_rating number(38) not null,
        bullet_games number(38) not null,
        bullet_rating number(38) not null,
        classical_games number(38) not null,
        classical_rating number(38) not null,
        rapid_games number(38) not null,
        rapid_rating number(38) not null,
        lang varchar2(20) not null,
        team_id number(38) not null,
        constraint fk_players foreign key (team_id) references teams(team_id) on delete cascade,
        constraint nonnegative check(blitz_games >= 0 AND bullet_games >= 0 AND classical_games >= 0 AND rapid_games >= 0),
        constraint positive_rating check(blitz_rating > 0 AND bullet_rating > 0 AND classical_rating > 0 AND rapid_rating > 0),
        constraint real_gender check(gender="male" OR gender="female"));
      ''');

      batch.execute('''
        Create table games(
        game_id varchar2(20) not null primary key,
        start_time timestamp(1) not null,
        end_time timestamp(1) not null,
        turns number(38) not null,
        status varchar2(20) not null,
        winner varchar2(20) not null,
        opening_name varchar2(100) not null,
        white_player_id varchar2(20) not null,
        black_player_id varchar2(20) not null,
        venue_id number(38) not null,
        time_duration number(38) not null,
        time_increment number(38) not null,
        
        constraint fk_games foreign key (white_player_id) references players(player_id) on delete cascade,
        constraint fk_games2 foreign key (black_player_id) references players(player_id) on delete cascade,
        constraint fk_games3 foreign key (venue_id) references venues(venue_id) on delete cascade,
        constraint fk_games4 foreign key (time_duration, time_increment) references TimeControls(time_duration, time_increment) on delete cascade,
        constraint valid_status check(status = "mate" OR status = "resign" OR status = "draw" OR status = "outoftime"),
        constraint valid_winner check(winner = "white" OR winner = "black" OR winner = "draw"));
      ''');
      await batch.commit();

      batch = db.batch();
      await batch.execute('''create table venue_insert_count(my_count number(38));''');
      await batch.execute('''insert into venue_insert_count values (0);''');
      await batch.commit();

      batch = db.batch();
      await batch.execute('''create trigger ven_ins_ct after insert on venues for each row
      begin update venue_insert_count set my_count = my_count+1; end''');
      await batch.commit();



      // batch = db.batch();
      // batch.execute('''insert into players values ('simplythebest1', 'binary', 10, 1500, 10, 1500, 10, 1500, 10, 1500, 'english', 10);''');
      // await batch.commit();

      batch = db.batch();
      await batch.execute('''CREATE VIEW experienced_managers AS 
        SELECT manager_id, manager_name, years_experience 
        FROM managers WHERE years_experience > 30;''');
      await batch.commit();

      // final directory = await getApplicationDocumentsDirectory();
      // final path = directory.path;
      // print(await rootBundle.loadString('assets/insertion_sql/insert_venues.sql'));
      await dbImportSql(db, 'insert_games.sql');
      await dbImportSql(db, 'insert_managers.sql');
      await dbImportSql(db, 'insert_players.sql');
      await dbImportSql(db, 'insert_teams.sql');
      // await dbImportSql(db, 'insert_venues.sql');
      await dbImportSql(db, 'insert_time_controls.sql');



      // batch = db.batch();
      // batch.rawInsert('''
      //   insert into VENUES (venue_id, venue_name, country, city)
      //   values (1, 'Memphis Chess Club', 'USA', 'Memphis, TN');
      // ''');
      // await batch.commit();

      print('initialized database');
    }, version: 1).catchError((error) => print('error: $error'));
  }


  Future<int> insertVenues() async {
    final db = await database;
    await dbImportSql(db, 'insert_venues.sql');
    return await getVenueInsertCount();
  }

  Future dbImportSql(Database db, String filename) async {
    print('importing $filename');
    try {
      String contents = await rootBundle.loadString('assets/insertion_sql/$filename');
      List<String> sqlStatements = contents.split('\n');

      var batch = db.batch();
      for (var statement in sqlStatements) {
        batch.execute(statement);
      }
      await batch.commit(noResult: true);
      print('$filename imported');
    } catch (e) {
      print('ERROR: $e');
    }
  }

  Future<int> getVenueInsertCount() async {
    final db = await database;
    List<Map<String, dynamic>> res = await db.rawQuery('''SELECT my_count FROM venue_insert_count;''');
    return res[0]['my_count'];
  }

  Future<List<Map<String, dynamic>>> genderDistributionQuery() async {
    final db = await database;
    List<Map> res = await db.rawQuery('''
          SELECT avg(females.positive) AS female,
          1-avg(females.positive) AS male
          FROM (SELECT (CASE WHEN gender='female' THEN 1 ELSE 0 END) AS positive from players) females;
        ''');

    return res;

    // return Future.delayed(
    //     Duration(seconds: 3), () => [{'male': 0.75, 'female': 0.25}]);
  }

  Future<List<Map<String, dynamic>>> mostExperiencedManagersQuery() async {
    final db = await database;
    return await db.rawQuery(''
        'SELECT manager_name, years_experience FROM managers WHERE years_experience >= (SELECT MAX(years_experience) FROM managers);');

    // return Future.delayed(Duration(seconds: 4), () =>
    // <Map<String, dynamic>>[
    //   {'MANAGER_ID': 100, 'YEARS_EXPERIENCE': 12},
    //   {'MANAGER_ID': 200, 'YEARS_EXPERIENCE': 12},
    //   {'MANAGER_ID': 300, 'YEARS_EXPERIENCE': 12}
    // ]);
  }

  // average draws per speed
  Future<List<Map<String, dynamic>>> avgDrawsBySpeedQuery() async {
    final db = await database;
    // return await db.rawQuery('''
    //   Select count(rapid.num_draws) AS rapid_draws, count(classical.num_draws) AS classical_draws
    //   From
    //     (
    //       Select (CASE games.status WHEN 'draw' THEN 1 ELSE 0 END) AS num_draws
    //       From games Natural Join timecontrols
    //       Where speed = 'rapid') rapid,
    //     (
    //       Select (CASE games.status WHEN 'draw' THEN 1 ELSE 0 END) AS num_draws
    //       From games Natural Join timecontrols
    //       Where speed = 'classical') classical;
    // ''');
      return await db.rawQuery('''
      SELECT speed, avg(CASE status WHEN 'draw' then 1 ELSE 0 END) AS avg_draws 
      FROM games NATURAL JOIN timecontrols GROUP BY speed;
    ''');
    // return Future.delayed(Duration(seconds: 2), () =>
    // [
    //   {'RAPID_DRAWS': 0.041, 'CLASSICAL_DRAWS': 0.062}
    // ]);
  }

  Future<List<Map<String, dynamic>>> gameStatusDistributionQuery() async {
    final db = await database;
    // return await db.rawQuery('''
    // WITH
    //   status_query AS (SELECT status, COUNT(*) AS status_count FROM games GROUP BY status),
    //   total_query AS (SELECT COUNT(*) AS total_count FROM games)
    // SELECT status, status_count / total_count
    // FROM status_query, total_query
    //
    // ''');
    return await db.rawQuery('SELECT status, COUNT(*) AS status_count FROM games GROUP BY status;');
    
    // return Future.delayed(Duration(seconds: 3), () =>
    // [
    //   {'status': 'mate', 'pct': 0.2},
    //   {'status': 'draw', 'pct': 0.1},
    //   {'status': 'outoftime', 'pct': 0.4},
    //   {'status': 'resign', 'pct': 0.3},
    // ]);
  }

  Future<List<Map<String, dynamic>>> numPPlayersQuery() async {
    final db = await database;
    return await db.rawQuery('''SELECT COUNT(PLAYER_ID) FROM players WHERE player_id LIKE 'p%' OR player_id LIKE 'P%';''');
    // return Future.delayed(
    //     Duration(seconds: 4), () => [{'COUNT(PLAYER_ID)': 734}]);
  }

  Future<List<Map<String, dynamic>>> getGames({String text}) async {
    final db = await database;
    return await db.rawQuery('''SELECT * FROM games WHERE 
      game_id LIKE \'%$text%\' OR
      start_time LIKE \'%$text%\' OR 
      status LIKE \'%$text%\' OR 
      winner LIKE \'%$text%\' OR 
      opening_name LIKE \'%$text%\' OR 
      white_player_id LIKE \'%$text%\' OR 
      black_player_id LIKE \'%$text%\' OR 
      venue_id LIKE \'%$text%\' OR 
      time_increment LIKE \'%$text%\' OR 
      time_duration LIKE \'%$text%\'
    ''');
    // return [{
    //   'game_id': '100',
    //   'start_time': '10:10:10',
    //   'status': 'mate',
    //   'winner': 'white',
    //   'opening_name': 'french',
    //   'white_player_id': 'dymusicguy',
    //   'black_player_id': 'budman',
    //   'venue_id': 1,
    //   'time_increment': 3,
    //   'time_duration': 5
    // }];
  }

  Future<List<Map<String, dynamic>>> getManagersBy({String text, String by, bool showExperiencedManagers}) async {
    final db = await database;
    final String tableName = showExperiencedManagers ? 'experienced_managers' : 'managers';
    switch (by) {
      case 'manager_name':
        return await db.rawQuery('SELECT * FROM $tableName WHERE manager_name LIKE \'%$text%\'');
        break;
      case 'years_experience':
        return await db.rawQuery('SELECT * FROM $tableName WHERE years_experience LIKE \'%$text%\'');
        break;
      default:
        throw Exception('Illegal by clause');
    }

    // if (by == 'manager_name') {
    //   return Future.delayed(Duration(seconds: 1), () =>
    //   [
    //     {'manager_id': 1, 'name': 'Sam', 'years_experience': 30},
    //     {'manager_id': 2, 'name': 'Johnson', 'years_experience': 35},
    //   ]);
    // } else if(by == 'years_experience') {
    //   return Future.delayed(Duration(seconds: 1), () =>
    //   [
    //     {'manager_id': 1, 'name': 'Sam', 'years_experience': 30},
    //     {'manager_id': 2, 'name': 'Johnson', 'years_experience': 35},
    //   ]);
    // } else {
    //   return Future.delayed(Duration(seconds: 1), () =>
    //   [
    //     {'manager_id': 1, 'name': 'Sam', 'years_experience': 30},
    //     {'manager_id': 2, 'name': 'Johnson', 'years_experience': 35},
    //   ]);
    // }
  }

  Future<List<Map<String, dynamic>>> getPlayersBy({String text, String by}) async {
    final db = await database;
    switch (by) {
      case 'player_id':
        return await db.rawQuery('SELECT player_id, lang, team_id FROM players WHERE player_id LIKE \'%$text%\'');
        break;
      case 'lang':
        return await db.rawQuery('SELECT player_id, lang, team_id FROM players WHERE lang LIKE \'%$text%\'');
        break;
      case 'team_id':
        return await db.rawQuery('SELECT player_id, lang, team_id FROM players WHERE team_id LIKE \'%$text%\'');
        break;
      default:
        throw Exception('Illegal by clause');
    }
    // if (by == 'language') {
    //   return Future.delayed(Duration(seconds: 1), () =>
    //   [
    //     {'player_id': 'dymusicguy', 'language': 'English'},
    //     {'player_id': 'budman', 'language': 'Lashon Hakodesh'},
    //   ]);
    // } else if(by == 'team_id') {
    //   return Future.delayed(Duration(seconds: 1), () =>
    //   [
    //     {'player_id': 'dymusicguy', 'team_id': 100},
    //     {'player_id': 'budman', 'team_id': 200},
    //   ]);
    // } else {
    //   return Future.delayed(Duration(seconds: 1), () =>
    //   [
    //     {'player_id': 'dymusicguy'},
    //     {'player_id': 'budman'},
    //   ]);
    // }
  }

  Future<List<Map<String, dynamic>>> getTeamsBy({String text, String by}) async {
    final db = await database;
    if (text == '') {
      return await db.rawQuery('SELECT team_id, manager_id FROM teams;');
    }
    switch (by) {
      case 'team_id':
        return await db.rawQuery('SELECT team_id, manager_id FROM teams WHERE team_id=?', [text]);
        break;
      case 'manager_id':
        return await db.rawQuery('SELECT team_id, manager_id FROM teams WHERE manager_id=?', [text]);
        break;
      default:
        throw Exception('Illegal by clause');
    }

    // return [
    //   { 'team_id': 100, 'manager_id': 1 },
    //   { 'team_id': 200, 'manager_id': 2 },
    // ];
  }

  Future<List<Map<String, dynamic>>> getVenuesBy({String text, String by}) async {
    final db = await database;
    switch (by) {
      case 'venue_name':
        return await db.rawQuery('SELECT venue_id, venue_name FROM venues WHERE venue_name LIKE \'%$text%\'');
        break;
      case 'country':
        return await db.rawQuery('SELECT venue_id, venue_name, country FROM venues WHERE country LIKE \'%$text%\'');
        break;
      case 'city':
        return await db.rawQuery('SELECT venue_id, venue_name, city FROM venues WHERE city LIKE \'%$text%\'');
        break;
      default:
        throw Exception("Illegal by clause");

    }
    return await db.rawQuery('SELECT venue_id, venue_name, $by FROM venues WHERE $by LIKE \'%$text%\';');
    // if (by == 'city') {
    //   return Future.delayed(Duration(seconds: 1), () =>
    //   [
    //     {'id': 100, 'city': 'memphis', 'name': 'Memphis Chess Club'},
    //     {'id': 200, 'city': 'jerusalem', 'name': 'Jerusalem Chess Club'},
    //   ]);
    // } else if(by == 'country') {
    //   return Future.delayed(Duration(seconds: 1), () =>
    //   [
    //     {'id': 100, 'country': 'US', 'name': 'Memphis Chess Club'},
    //     {'id': 200, 'country': 'Israel', 'name': 'Jerusalem Chess Club'},
    //   ]);
    // } else {
    //   return Future.delayed(Duration(seconds: 1), () =>
    //   [
    //     {'id': 100, 'name': 'Memphis Chess Club'},
    //     {'id': 200, 'name': 'Jerusalem Chess Club'},
    //   ]);
    // }
  }

  Future<Map<String, dynamic>> getGameById(String id) async {
    print('Running getGameById');
    final db = await database;
    return await db.rawQuery('SELECT * FROM games WHERE game_id = \'$id\'').then((result) => result[0]);

    // return Future.delayed(Duration(seconds: 1), () => {
    //   '100': {
    //     'game_id': '100',
    //     'start_time': '10:10:10',
    //     'status': 'mate',
    //     'winner': 'white',
    //     'opening_name': 'french',
    //     'white_player_id': 'dymusicguy',
    //     'black_player_id': 'budman',
    //     'venue_id': 1,
    //     'time_increment': 3,
    //     'time_duration': 5
    //   },
    //   'budman': { 'player_id': 'budman', 'language': 'lashon hakodesh', 'team_id': 200 },
    // }[id]);
  }

  Future<Map<String, dynamic>> getManagerById(int id) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM managers WHERE manager_id=?', [id]).then((result) => result[0]);
    // return Future.delayed(Duration(seconds: 1), () => {
    //   1: {'manager_id': 1, 'manager_name': 'Sam', 'years_experience': 30},
    //   2: {'manager_id': 2, 'manager_name': 'Johnson', 'years_experience': 35},
    // }[id]);
  }

  Future<Map<String, dynamic>> getPlayerById(String id) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM players WHERE player_id=?', [id]).then((result) => result[0]);
    // return Future.delayed(Duration(seconds: 1), () => {
    //   'dymusicguy': { 'player_id': 'dymusicguy', 'language': 'english', 'team_id': 100 },
    //   'budman': { 'player_id': 'budman', 'language': 'lashon hakodesh', 'team_id': 200 },
    // }[id]);
  }

  Future<Map<String, dynamic>> getTeamById(int id) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM teams WHERE team_id=?', [id]).then((result) => result[0]);
    // return Future.delayed(Duration(seconds: 1), () => {
    //   100: { 'team_id': 100, 'manager_id': 1 },
    //   200: { 'team_id': 200, 'manager_id': 2 },
    // }[id]);
  }

  Future<Map<String, dynamic>> getVenueById(int id) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM venues WHERE venue_id=?', [id]).then((result) => result[0]);
    // return Future.delayed(Duration(seconds: 1), () => {
    //   100: { 'venue_id': 100, 'venue_name': 'Memphis Chess Club', 'country': 'USA', 'city': 'Memphis' },
    //   200: { 'venue_id': 200, 'venue_name': 'Jerusalem Chess Club', 'country': 'Israel', 'city': 'Jerusalem' },
    // }[id]);
  }

  Future<Map<String, dynamic>> numGamesPlayedInVenueQuery(int id) async {
    final db = await database;

    return await db.rawQuery('SELECT count(venue_id) FROM games NATURAL JOIN venues WHERE venue_id = \'$id\'').then((result) => result[0]);

    // return Future.delayed(Duration(seconds: 1), () => {
    //   100: { 'COUNT(VENUE_ID)': 1140 },
    //   200: { 'COUNT(VENUE_ID)': 2000 },
    // }[id]);
  }

  Future<Map<String, dynamic>> avgTeamRatingBySpeedQuery(int team_id, String speed) async {
    final db = await database;
    return await db.rawQuery('SELECT avg(${speed}_rating) AS rating FROM players WHERE team_id=$team_id').then((result) => result[0]);

    // return Future.delayed(Duration(seconds: 1), () => {
    //   100: [ {'speed': 'rapid', 'rating': 2040}, {'speed': 'classical', 'rating': 2000}, {'speed': 'bullet', 'rating': 2010} ],
    //   200: [ {'speed': 'rapid', 'rating': 1500}, {'speed': 'classical', 'rating': 1720}, {'speed': 'bullet', 'rating': 1312} ],
    // }[id]);
  }

  Future<List<Map<String, dynamic>>> getPlayersByManager(int manager_id) async {
    final db = await database;
    return await db.rawQuery('SELECT player_id FROM players NATURAL JOIN teams WHERE manager_id = ?;', [manager_id]);
  }
}