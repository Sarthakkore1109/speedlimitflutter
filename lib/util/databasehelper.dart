import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/adjacentlocationaddmodel.dart';
import '../model/locationaddmodel.dart';

class DatabaseHelper {
  static const _databasename = 'Locations.db';
  static const _databaseversion = 1;

  //Singleton Class
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  late Database _database;
  late Batch batch;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory(); //Original One
    //TODO: Change this value to either internal or external directory afterwards.
    //Directory dataDirectory = await getExternalStorageDirectory(); //For Android 9
    String dbPath = join(dataDirectory.path, _databasename);
    print(dbPath);
    return await openDatabase(dbPath,
        version: _databaseversion, onCreate: _onCreateDB);
  }

  _onCreateDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${LocationAdder.tblLocationadder}(
    ${LocationAdder.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${LocationAdder.colName} TEXT NOT NULL,
    ${LocationAdder.colLongitude} REAL NOT NULL,
    ${LocationAdder.colLatitude} REAL NOT NULL,
    ${LocationAdder.colRegion} INTEGER NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE ${AdjacentLocation.tblAdjacentLocationadder}(
    ${AdjacentLocation.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${AdjacentLocation.colSName} TEXT NOT NULL,
    ${AdjacentLocation.colSId} INTEGER NOT NULL,
    ${AdjacentLocation.colEName} TEXT NOT NULL,
    ${AdjacentLocation.colEId} INTEGER NOT NULL,
    ${AdjacentLocation.colSpeedLimit} REAL NOT NULL,
    ${AdjacentLocation.colSpecialLocation} INTEGER NOT NULL,
    ${AdjacentLocation.colPermissibleSpeed} INTEGER NOT NULL
    )
    ''');
  }

  //For Location Table
  //To insert into database
  Future<int> insertLocation(LocationAdder locationAdder) async {
    Database db = await database;
    return await db.insert(
      LocationAdder.tblLocationadder,
      //locationAdder.toMap(),
      locationAdder.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //To update data
  Future<int> updateLocation(LocationAdder locationAdder) async {
    Database db = await database;
    return await db.update(
        LocationAdder.tblLocationadder,
        //locationAdder.toMap(),
        locationAdder.toJson(),
        where: '${LocationAdder.colId} = ?',
        whereArgs: [locationAdder.id]);
  }

  //To delete data
  Future<int> deleteLocation(int id) async {
    Database db = await database;
    String sqlQuery = "DELETE FROM adjacentlocations WHERE (start_id = $id) OR (end_Id = $id)";
    db.rawQuery(sqlQuery);
    return await db.delete(LocationAdder.tblLocationadder,
        where: '${LocationAdder.colId} = ?', whereArgs: [id]);
  }

  //to fetch database list

  Future<List<LocationAdder>> fetchLocation() async {
    Database db = await database;
    List<Map> location = await db.query(LocationAdder.tblLocationadder);
    return location.length == 0 ? [] : location.map((e) =>
    //LocationAdder.fromMap(e)).toList();
    LocationAdder.fromJson(e)).toList();
  }

  //=====================================================================================================
  //For AdjacentLocation table
  //To add entry into table
  Future<int> insertAdjLocation(AdjacentLocation adjacentLocation) async {
    Database db = await database;
    return await db.insert(
      AdjacentLocation.tblAdjacentLocationadder,
      //adjacentLocation.toMap(),
      adjacentLocation.toJson(),
      //conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //To update data
  Future<int> updateAdjLocation(AdjacentLocation adjacentLocation) async {
    Database db = await database;

    return await db.update(
        AdjacentLocation.tblAdjacentLocationadder,
        //adjacentLocation.toMap(),
        adjacentLocation.toJson(),
        where: '${AdjacentLocation.colId} = ?',
        whereArgs: [adjacentLocation.id]);

  }

  Future<int> reverseUpdate(int start_id, String start_name, int end_Id, String end_name, double speed_limit, int original_SID, int original_EID) async{
    Database  db = await database;
    String sql = "UPDATE adjacentlocations SET start_id = $start_id, start_name = '$start_name', end_Id = $end_Id, end_name = '$end_name, speed_limit = $speed_limit, WHERE start_id = $original_SID AND end_Id = $original_EID ";

    db.rawQuery(sql);
    return 1;
  }

  Future<List<AdjacentLocation>?> getidLocation(String start_name, String end_name) async{
    Database db = await database;
    String sql = "SELECT * FROM adjacentlocations WHERE start_name = '$start_name' AND end_name = '$end_name'";
    var result = await db.rawQuery(sql);
    if (result.length == 0) return null;

    List<AdjacentLocation> list = result.map((item) {
      //return AdjacentLocation.fromMap(item);
      return AdjacentLocation.fromJson(item);
    }).toList();

    //print(result);
    return list;

  }

  //To delete data
  Future<int> deleteAdjLocation(int id, int startId, int endId) async {
    Database db = await database;
    String sqlQuery = "DELETE FROM adjacentlocations WHERE ( start_id = $endId AND end_Id =$startId)";
    //await db.rawQuery(sqlQuery);
    await db.delete(AdjacentLocation.tblAdjacentLocationadder,
        where: '${AdjacentLocation.colSName} = ? AND ${AdjacentLocation.colEName} = ?', whereArgs: [endId,startId]);
    return await db.delete(AdjacentLocation.tblAdjacentLocationadder,
        where: '${AdjacentLocation.colId} = ?', whereArgs: [id]);
  }

  //to fetch database list

  Future<List<AdjacentLocation>> fetchAdjLocation() async {
    Database db = await database;
    List<Map> adjlocation =
    await db.query(AdjacentLocation.tblAdjacentLocationadder);
    return adjlocation.length == 0 ? [] : adjlocation.map((e) =>
    //AdjacentLocation.fromMap(e)).toList();
    AdjacentLocation.fromJson(e) ).toList();
  }

//=====================================================================================================
  Future<List<Map>> fetchSquaresOnly(String arg) async {
    Database db = await database;
    return await db.rawQuery(arg);
  }

  //For calling the whole object LocationAdder
  Future<List<LocationAdder>?> getLocationAdderModelData() async {
    Database db = await database;
    String sql;
    sql = "SELECT * FROM locations";

    var result = await db.rawQuery(sql);
    if (result.length == 0) return null;

    List<LocationAdder> list = result.map((item) {
      //return LocationAdder.fromMap(item);
      return LocationAdder.fromJson(item);
    }).toList();

    print(result);
    return list;
  }

  Future<List<LocationAdder>?> getLocationWithFilter(double myLatitudeLw,
      double myLatitudeUp, double myLongitudeLw, double myLongitudeUp) async {
    Database db = await database;
    String sql;
    sql =
    "SELECT * FROM locations WHERE (latitude BETWEEN $myLatitudeLw AND $myLatitudeUp) AND (longitude BETWEEN $myLongitudeLw AND $myLongitudeUp)";

    var result = await db.rawQuery(sql);
    if (result.length == 0) return null;

    List<LocationAdder> list = result.map((item) {
      //return LocationAdder.fromMap(item);
      return LocationAdder.fromJson(item);
    }).toList();

    //print(result);
    return list;
  }

  Future<List<LocationAdder>?> getLocationWithFilterAndRegion(double myLatitudeLw, double myLatitudeUp, double myLongitudeLw, double myLongitudeUp,int regionCode) async {
    Database db = await database;
    String sql;
    sql =
    "SELECT * FROM locations WHERE ((latitude BETWEEN $myLatitudeLw AND $myLatitudeUp) AND (longitude BETWEEN $myLongitudeLw AND $myLongitudeUp) AND (region == $regionCode)) ";

    var result = await db.rawQuery(sql);
    if (result.length == 0) return null;

    List<LocationAdder> list = result.map((item) {
      //return LocationAdder.fromMap(item);
      return LocationAdder.fromJson(item);
    }).toList();

    //print(result);
    return list;
  }

  Future<List<AdjacentLocation>?> getAdjacentLocationSpecific(int id) async {
    //print('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++getAdjacentLocationSpecific');
    Database db = await database;
    String sql;
    sql = "SELECT * FROM adjacentlocations WHERE start_id = $id";

    var result = await db.rawQuery(sql);
    if (result.length == 0) return null;

    List<AdjacentLocation> list = result.map((item) {
      //return AdjacentLocation.fromMap(item);
      return AdjacentLocation.fromJson(item);
    }).toList();

    //print(result);
    return list;
  }

  Future<List<LocationAdder>?> getLocationInfo(String e_name) async {
    Database db = await database;
    String sql;
    sql = "SELECT * FROM locations WHERE name == '$e_name'";

    var result = await db.rawQuery(sql);
    if (result.length == 0) return null;

    List<LocationAdder> list = result.map((item) {
      //return LocationAdder.fromMap(item);
      return LocationAdder.fromJson(item);
    }).toList();

    print(result);
    return list;
  }

  Future<List<LocationAdder>> getAdjLocationInfoList(int start_id) async{
    List<LocationAdder> result = [];
    List<AdjacentLocation>? tempList = await getAdjacentLocationSpecific(start_id);
    int length = tempList!.length;

    if(tempList != null && length>0) {
      for (int i = 0; i< length; i++){
        var tempAdd = await getLocationInfo(tempList[i].end_name);
        result.add(tempAdd![0]);
      }
    }

    return result;


  }

  Future<bool?> exportDatabase() async {
    //Module done
    try{
      if (_database != null) {
        Database db = await database;

        String sqlLocation;
        String sqlAdjLocation;
        String sqlSpecialLocation;
        String sqlRegion;
//--------------------------LOCATION data exporting---------------------------------------------
        sqlLocation = "SELECT * FROM locations";
        var resultLocation = await db.rawQuery(sqlLocation);
        if (resultLocation.length == 0) return null;
        List<LocationAdder> listLoc = resultLocation.map((item) {
          return LocationAdder.fromJson(item);
        }).toList();

        // target file
        final targetDir = await getExternalStorageDirectory();
        final targetPath = join(targetDir.path, 'ExportedDataLocations.json');
        File targetFile = File(targetPath);
        print("Target Path" + targetPath);
        print(listLoc);
        var jsonEncoder = jsonEncode(resultLocation);
        await targetFile.writeAsString(jsonEncoder, flush: true);

//--------------------------LOCATION data exporting ends---------------------------------------------

//--------------------------ADJACENT LOCATION data exporting---------------------------------------------

        sqlAdjLocation = "SELECT * FROM adjacentlocations";
        var resultAdjacentLoc = await db.rawQuery(sqlAdjLocation);
        if (resultAdjacentLoc.length == 0) return null;

        List<AdjacentLocation> listAdjLoc = resultAdjacentLoc.map((item) {
          return AdjacentLocation.fromJson(item);
        }).toList();

        final targetDirAL = await getExternalStorageDirectory();
        final targetPathAl = join(targetDirAL.path, 'ExportedDataAdjLocations.json');
        File targetFileAL = File(targetPathAl);
        print("Target Path" + targetPathAl);
        print(listAdjLoc);
        var jsonEncoderAL = jsonEncode(resultAdjacentLoc);
        await targetFileAL.writeAsString(jsonEncoderAL, flush: true);

//--------------------------ADJACENT LOCATION data exporting ends---------------------------------------------

//--------------------------SPECIAL LOCATION data exporting---------------------------------------------


//--------------------------SPECIAL LOCATION data exporting ends---------------------------------------------
//--------------------------REGION data exporting ends---------------------------------------------

//--------------------------REGION data exporting ends---------------------------------------------

        //Modified code
        /*String sqlMOdified = "SELECT * FROM locations";

      var result = await db.rawQuery(sqlMOdified);
      //print(length.length);

      for(int i=0;i<result.length;i++){
        print(result[i]);
        var start_id = result[i]['id'];

        String sqlMOdified2 = "SELECT * FROM adjacentlocations WHERE start_id == $start_id";
        var resultAdj = await db.rawQuery(sqlMOdified2);

        print(sqlMOdified2);
        //print(resultAdj);

        for(int j=0;j<resultAdj.length;j++){
          print(resultAdj[j]);
        }
      }*/

        //return 'Database copied to $targetPath & $targetPathAl';
        return true;
      }
    }catch(e){
      print(e);
      return false;
    }


    /*else {
      //return 'No database found!. please create a database first';
      return false;
    }*/
  }

  Future<bool> importDatabase() async {
    //try{
      if (_database != null) {
        Database db = await database;

        //================================================ For Location insertion ONLY=========================================
        String deleteExistingData = "DELETE FROM locations";
        String deleteExsistingDataCounter =
            "DELETE FROM sqlite_sequence WHERE name = 'locations'";
        await db.rawQuery(deleteExistingData);
        await db.rawQuery(deleteExsistingDataCounter);
        await db.execute("VACUUM");

        String LocationAddQuery;

        //NewSource
        final sourceDir = await getExternalStorageDirectory();
        final sourcePath = join(sourceDir.path, 'ExportedDataLocations.json');
        File sourceFile = File(sourcePath);
        String content = await sourceFile.readAsString();
        print(content);

        /* var json = jsonEncode(content);
      print("+++++++++++++++++++++++++++++++++++++"+json);*/

        var json2 = jsonDecode(content);
        var jsondecode = json.decode(content);
        int lengthOfJson = (json2 as List).length;

        print(lengthOfJson);

        for (int x = 0; x < lengthOfJson; x++) {
          print(json2[x]['name'] +
              json2[x]['longitude'].toString() +
              json2[x]['latitude'].toString()+
              json2[x]['region'].toString()
          );
          String Name = json2[x]['name'];
          double jLongitude = double.parse(json2[x]['longitude'].toString());
          double jLatitude = double.parse(json2[x]['latitude'].toString());
          int id = int.parse(json2[x]['id'].toString());
          int regionCode = int.parse(json2[x]['region'].toString());
          LocationAddQuery =
              "INSERT INTO locations (id,name,longitude,latitude,region) VALUES ($id,'$Name',$jLongitude,$jLatitude,$regionCode)";
          print(LocationAddQuery);
          db.execute(LocationAddQuery);
        }

        //================================================ For Location insertion ONLY ENDS=========================================

        //================================================ For SPECIAL Location insertion ONLY=========================================

        //================================================ For Adjacent Location insertion ONLY Starts=========================================

        String deleteExistingDataAl = "DELETE FROM adjacentlocations";
        String deleteExistingDataAlCounter =
            "DELETE FROM sqlite_sequence WHERE name = 'adjacentlocations'";
        await db.rawQuery(deleteExistingDataAl);
        await db.rawQuery(deleteExistingDataAlCounter);
        await db.execute("VACUUM");

        String sqlAdjacentLocationAddQuery;

        //NewSource
        final sourceDirAL = await getExternalStorageDirectory();
        final sourcePathAL =
            join(sourceDirAL.path, 'ExportedDataAdjLocations.json');
        File sourceFileAL = File(sourcePathAL);
        String contentAL = await sourceFileAL.readAsString();
        print(contentAL);

        var json2AL = jsonDecode(contentAL);
        var jsondecodeAL = json.decode(contentAL);
        int lengthOfJsonAL = (json2AL as List).length;

        print(lengthOfJsonAL);

        for (int y = 0; y < lengthOfJsonAL; y++) {
          print(json2AL[y]['start_name'] +
              json2AL[y]['start_id'].toString() +
              json2AL[y]['end_name'] +
              json2AL[y]['end_Id'].toString() +
              json2AL[y]['speed_limit'].toString()+
              json2AL[y]['special_location'].toString()+
              json2AL[y]['permissible_speed'].toString());
          String start_Name = json2AL[y]['start_name'];
          //print(start_Name);
          int start_id = int.parse(json2AL[y]['start_id'].toString());
          //print(start_id);
          String end_Name = json2AL[y]['end_name'];
          //print(end_Name);
          int end_Id = int.parse(json2AL[y]['end_Id'].toString());
          //print(end_Id);
          double speed_Limit =
              double.parse(json2AL[y]['speed_limit'].toString());
          //print(speed_Limit);
          int special_location_type = int.parse(json2AL[y]['special_location'].toString());
          int permissible_speed_limit = int.parse(json2AL[y]['permissible_speed'].toString());
          sqlAdjacentLocationAddQuery =
              "INSERT INTO adjacentlocations (start_name,start_id,end_name,end_id,speed_limit,special_location,permissible_speed) VALUES('$start_Name',$start_id,'$end_Name',$end_Id,$speed_Limit,$special_location_type,$permissible_speed_limit)";
          print(sqlAdjacentLocationAddQuery);
          db.execute(sqlAdjacentLocationAddQuery);
        }

        //================================================ For Adjacent Location insertion ONLY Ends=========================================

        print("source path: " + sourcePath);

        //return 'Database copied to \$targetPath';
        return true;
      } else {
        //return 'No database found!. please create a database first';
        return false;
      }
    /*}catch(e){
      print('error'+e.toString());
      return false;
    }*/
  }

  Future<int> initializingDatabase() async {

    if(database != null){
      Database db = await database;
      String sql;
      sql = "SELECT * FROM locations LIMIT 1";
      var result = await db.rawQuery(sql);
      print(result);
      return 1;
    }else{
      print('NO DATABASE');
      return 0;
    }

  }

  Future<bool> importDatabaseOnline(List jsonLocation,List jsonAdjLocation,List jsonSpecialLocation, List jsonRegion, List jsonDatabase) async {
    try{
      if (_database != null) {
        Database db = await database;
        batch = db.batch();

        //================================================ For Location insertion ONLY=========================================
        String deleteExistingData = "DELETE FROM locations";
        String deleteExsistingDataCounter =
            "DELETE FROM sqlite_sequence WHERE name = 'locations'";
        await db.rawQuery(deleteExistingData);
        await db.rawQuery(deleteExsistingDataCounter);
        await db.execute("VACUUM");

        String LocationAddQuery;

        //NewSource
        /*final sourceDir = await getExternalStorageDirectory();
        final sourcePath = join(sourceDir.path, 'ExportedDataLocations.json');
        File sourceFile = File(sourcePath);
        String content = await sourceFile.readAsString();
        print(content);*/

        /* var json = jsonEncode(content);
      print("+++++++++++++++++++++++++++++++++++++"+json);*/

        //var json2 = jsonDecode(content);
        //var jsondecode = json.decode(content);
        int lengthOfJson = jsonLocation.length;

        print(lengthOfJson);

        for (int x = 0; x < lengthOfJson; x++) {
         /* print(jsonLocation[x]['name'] +
              jsonLocation[x]['longitude'].toString() +
              jsonLocation[x]['latitude'].toString()+
              jsonLocation[x]['region'].toString());*/
          String Name = jsonLocation[x]['name'];
          double jLongitude = double.parse(jsonLocation[x]['longitude'].toString());
          double jLatitude = double.parse(jsonLocation[x]['latitude'].toString());
          int jRegion = int.parse(jsonLocation[x]['region'].toString());
          int id = int.parse(jsonLocation[x]['id'].toString());
          //LocationAddQuery = "INSERT INTO locations (id,name,longitude,latitude,region) VALUES ($id,'$Name',$jLongitude,$jLatitude,$jRegion)";
          //print(LocationAddQuery);
          //db.execute(LocationAddQuery);
          
          batch.insert('locations', {'id': '$id', 'name': '$Name','longitude': '$jLongitude','latitude':'$jLatitude','region':'$jRegion'});
        }

        //================================================ For Location insertion ONLY ENDS=========================================

        //================================================ For SPECIAL Location insertion ONLY=========================================

        String deleteExistingDataSL = "DELETE FROM special_location";
        String deleteExsistingDataCounterSL = "DELETE FROM sqlite_sequence WHERE name = 'special_location'";
        await db.rawQuery(deleteExistingDataSL);
        await db.rawQuery(deleteExsistingDataCounterSL);
        await db.execute("VACUUM");

        String LocationAddQuerySL;

        int lengthOfJsonSL = jsonSpecialLocation.length;

        print(lengthOfJsonSL);

        for (int x = 0; x < lengthOfJsonSL; x++) {
          print(jsonSpecialLocation[x]['id'].toString() +
              jsonSpecialLocation[x]['type']);
          String typeSL = jsonSpecialLocation[x]['type'];
          int idSL = int.parse(jsonSpecialLocation[x]['id'].toString());
          LocationAddQuerySL = "INSERT INTO special_location (id,type) VALUES ($idSL,'$typeSL')";
          print(LocationAddQuerySL);
          db.execute(LocationAddQuerySL);
          //batch.insert("special_location", {"id":"$idSL","type":"$typeSL"});
        }

        //================================================ For SPECIAL Location insertion ONLY ENDS=========================================

        //================================================ For Region insertion ONLY Starts=========================================
        String deleteExistingDataR = "DELETE FROM region";
        String deleteExsistingDataCounterR = "DELETE FROM sqlite_sequence WHERE name = 'region'";
        await db.rawQuery(deleteExistingDataR);
        await db.rawQuery(deleteExsistingDataCounterR);
        await db.execute("VACUUM");

        String LocationAddQueryR;

        /*//NewSource
        final sourceDirR = await getExternalStorageDirectory();
        final sourcePathR = join(sourceDirR.path, 'ExportedDataRegions.json');
        File sourceFileR = File(sourcePathR);
        String contentR = await sourceFileR.readAsString();
        print(contentR);

        *//* var json = jsonEncode(content);
      print("+++++++++++++++++++++++++++++++++++++"+json);*//*

        var json2R = jsonDecode(contentR);
        var jsondecodeR = json.decode(contentR);*/
        int lengthOfJsonR = jsonRegion.length;

        print(lengthOfJsonR);

        for (int x = 0; x < lengthOfJsonR; x++) {
          print(jsonRegion[x]['id'].toString() +
              jsonRegion[x]['name']);
          String nameR = jsonRegion[x]['name'];
          int idR = int.parse(jsonRegion[x]['id'].toString());
          LocationAddQueryR = "INSERT INTO region (id,name) VALUES ($idR,'$nameR')";
          print(LocationAddQueryR);
          db.execute(LocationAddQueryR);
        }
        //================================================ For Region insertion ONLY ENDS=========================================

        //================================================ For DatabaseVersionControl insertion ONLY starts=========================================
        String deleteExistingDataDB = "DELETE FROM database_version";
        String deleteExsistingDataCounterDB = "DELETE FROM sqlite_sequence WHERE name = 'database_version'";
        await db.rawQuery(deleteExistingDataDB);
        await db.rawQuery(deleteExsistingDataCounterDB);
        await db.execute("VACUUM");

        String LocationAddQueryDBVCS;

        /*//NewSource
        final sourceDirR = await getExternalStorageDirectory();
        final sourcePathR = join(sourceDirR.path, 'ExportedDataRegions.json');
        File sourceFileR = File(sourcePathR);
        String contentR = await sourceFileR.readAsString();
        print(contentR);

        *//* var json = jsonEncode(content);
      print("+++++++++++++++++++++++++++++++++++++"+json);*//*

        var json2R = jsonDecode(contentR);
        var jsondecodeR = json.decode(contentR);*/
        int lengthOfJsonDB = jsonDatabase.length;
        print(lengthOfJsonDB);

        for (int x = 0; x < lengthOfJsonDB; x++) {
          /*print(jsonDatabase[x]['id'].toString() +
              jsonDatabase[x]['name']);
          String nameDB = jsonDatabase[x]['name'];
          int idDB = int.parse(jsonDatabase[x]['id'].toString());*/
          //LocationAddQueryDBVCS = "INSERT INTO database_version (id,name) VALUES ($idDB,'$nameDB')";
          //print(LocationAddQueryDBVCS);
          //db.execute(LocationAddQueryDBVCS);
          String nameDB = jsonDatabase[x];
          batch.insert('database_version', {'name':'$nameDB'});
        }

        //================================================ For DatabaseVersionControl insertion ONLY ENDS=========================================

        //================================================ For Adjacent Location insertion ONLY Starts=========================================

        String deleteExistingDataAl = "DELETE FROM adjacentlocations";
        String deleteExistingDataAlCounter =
            "DELETE FROM sqlite_sequence WHERE name = 'adjacentlocations'";
        await db.rawQuery(deleteExistingDataAl);
        await db.rawQuery(deleteExistingDataAlCounter);
        await db.execute("VACUUM");

        String sqlAdjacentLocationAddQuery;

        //NewSource
        /*final sourceDirAL = await getExternalStorageDirectory();
        final sourcePathAL =
        join(sourceDirAL.path, 'ExportedDataAdjLocations.json');
        File sourceFileAL = File(sourcePathAL);
        String contentAL = await sourceFileAL.readAsString();
        print(contentAL);*/

        //var json2AL = jsonDecode(contentAL);
        //var jsondecodeAL = json.decode(contentAL);
        int lengthOfJsonAL = jsonAdjLocation.length;

        print(lengthOfJsonAL);

        for (int y = 0; y < lengthOfJsonAL; y++) {
          /*print(jsonAdjLocation[y]['start_name'] +
              jsonAdjLocation[y]['start_id'].toString() +
              jsonAdjLocation[y]['end_name'] +
              jsonAdjLocation[y]['end_Id'].toString() +
              jsonAdjLocation[y]['speed_limit'].toString()+
              jsonAdjLocation[y]['special_location'].toString()+
              jsonAdjLocation[y]['permissible_speed'].toString());*/
          String start_Name = jsonAdjLocation[y]['start_name'];
          //print(start_Name);
          int start_id = int.parse(jsonAdjLocation[y]['start_id'].toString());
          //print(start_id);
          String end_Name = jsonAdjLocation[y]['end_name'];
          //print(end_Name);
          int end_Id = int.parse(jsonAdjLocation[y]['end_Id'].toString());
          //print(end_Id);
          double speed_Limit =
          double.parse(jsonAdjLocation[y]['speed_limit'].toString());
          //print(speed_Limit);
          int special_location_type = int.parse(jsonAdjLocation[y]['special_location'].toString());
          int permissibleSpeedLimit = int.parse(jsonAdjLocation[y]['special_location'].toString());
          //int id = int.parse(jsonAdjLocation[y]['id'].toString());
          //sqlAdjacentLocationAddQuery = "INSERT INTO adjacentlocations (start_name,start_id,end_name,end_id,speed_limit,special_location,permissible_speed) VALUES('$start_Name',$start_id,'$end_Name',$end_Id,$speed_Limit,$special_location_type,$permissibleSpeedLimit)";
          //print(sqlAdjacentLocationAddQuery);
          //db.execute(sqlAdjacentLocationAddQuery);
          batch.insert('adjacentlocations', {'start_name':'$start_Name','start_id':'$start_id','end_name':'$end_Name','end_id':'$end_Id','speed_limit':'$speed_Limit','special_location':'$special_location_type','permissible_speed':'$permissibleSpeedLimit'});

        }
        await batch.commit(noResult: true);
        //================================================ For Adjacent Location insertion ONLY Starts=========================================

        //print("source path: " + sourcePath);

        //return 'Database copied to \$targetPath';
        return true;
      } else {
        //return 'No database found!. please create a database first';
        return false;
      }
    }catch(e){
      print('error'+e.toString());
      return false;
    }
  }
}
