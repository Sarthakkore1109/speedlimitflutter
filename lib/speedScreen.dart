import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:speedlimitflutter/util/databasehelper.dart';
import 'package:latlong/latlong.dart';
import 'model/adjacentlocationaddmodel.dart';
import 'model/locationaddmodel.dart';

List<double> distanceAdjSquareModule = [];
List<double> distanceAdjSquareToBase = [];
List<double> distancePRINTINGPURPOSE = [];
List<double> anglesBaseAdjLoc = [];
List<double> angleBaseAdjLocDegree = [];
List<Offset> coOrdinatesLocations = [];
List<double> nextLocationSpeedLimit = [];
List<double> nextLocationPermissibleSpeedLimit = [];

List<LocationAdder> nextLocationDetail = [];
List<LocationAdder> nextLocationDetailNEW = [];
List<AdjacentLocation> nextLocationsAdjacentLocation = [];

double speed = 0.0;
String speedinKMPH = '';
double changingLat = 0;
double changingLong = 0;

double locationLimit = 0.00036;
double locationLimitBig = 0.005;

late double baseLong;
late double baseLat;
late String baseName = "";
late int baseId;


late double meters;
late double distanceNearbyLocation;
late int distanceNearbyLocationID;
int distanceNearbyLocationIDVerifier = -1;
int distanceNearbyLocationIDVerifier2 = -1;
int nearbyLocationVerifier = -1;
late String distanceNearbyLocationName;

List<AdjacentLocation>? adjacentLocationNEARBY;
int nextLocationDetailListLength = 0;
String lastBaseName = "NA";

double nextLocationLatGB = 0;
double nextLocationLongGB = 0;
String nextLocationNameGB = "";
late int nextLocationIdGB;

int isSpecialLocationNearby = -1;
String specialLocationStr = "";
double speedLimitForColor = 140;
double speedNumber = 0;
int myspeed123 = speedNumber.toInt();
//Color textColor = Color.white;
double initialSpeedNumber = 0;
int initialSpecialLocation = -1;
int currentPML = 0;
int totalPML = 120; //was 50 changed to 120
int forceStopAlert = 0;
bool isOverSpeeding = false;

int usersCustomPML = 0;
int nextLocationsAdjacentLocationLength = -1;
double refreshRate = 0;
late Timer _timer;


class SpeedScreen extends StatefulWidget {
  const SpeedScreen({Key? key}) : super(key: key);

  @override
  State<SpeedScreen> createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {

  late LocationData currentLocation;
  Location location = Location();
  late DatabaseHelper _dbHelper;
  Distance distanceCalculator = Distance();


  @override
  void initState(){
    if (!mounted) return;

    repeatingFunc();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    super.initState();
  }

  @override
  void dispose(){
    clearLists();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  repeatingFunc() async {
    setInitialLocation();
    Future.delayed(Duration(seconds: 5), () {
      if (changingLong == null || changingLat == null) {
        setInitialLocation();
      }
    });
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      getBaseSquares();
    });
  }

  clearLists() {
    nextLocationsAdjacentLocation.clear();
    nextLocationDetailNEW.clear();
    nextLocationDetail.clear();
    distanceAdjSquareModule.clear();
    distanceAdjSquareToBase.clear();
    distancePRINTINGPURPOSE.clear();
    anglesBaseAdjLoc.clear();
    angleBaseAdjLocDegree.clear();
    coOrdinatesLocations.clear();
    nextLocationSpeedLimit.clear();
  }

  _locationService() {
    //location = new Location();

    location.enableBackgroundMode(enable: true);

    LocationAccuracy accuracy = LocationAccuracy.high;
    int interval = 200;
    double distanceFilter = 0.5;

    location.changeSettings(
        accuracy: accuracy, interval: interval, distanceFilter: distanceFilter);
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      //speed = currentLocation.speed;
      if (!mounted) return;
      //setState(() {
      speed = currentLocation.speed;
      speedinKMPH =
          (speed == null ? 0.0 : speed * 3.6).toStringAsFixed(0) + " Km/h";
      //dateTimeStamp = currentLocation.time;
      //convertedDateTimeStamp = DateTime.fromMillisecondsSinceEpoch(dateTimeStamp.toInt());
      //});
      changingLat = currentLocation.latitude == null ? 0.0 : currentLocation.latitude;
      changingLong = currentLocation.longitude == null ? 0.0 : currentLocation.longitude;
    });
  }

  setInitialLocation() async {
    currentLocation = await location.getLocation();
    _locationService();
  }

  getBaseSquares() async {
    /*double myLatitudeUp = currentLocation.latitude + 0.0005;
    double myLatitudeLw = currentLocation.latitude - 0.0005;*/
    double myLatitudeUp = currentLocation.latitude + locationLimit;
    double myLatitudeLw = currentLocation.latitude - locationLimit;
    //print(myLatitudeUp);
    //print(myLatitudeLw);

    /*double myLongitudeUp = currentLocation.longitude + 0.0005; 50 meters
    double myLongitudeLw = currentLocation.longitude - 0.0005;*/
    double myLongitudeUp = currentLocation.longitude + locationLimit;
    double myLongitudeLw = currentLocation.longitude - locationLimit;
    //print(myLongitudeUp);
    //print(myLongitudeLw);

    List<LocationAdder>? tempListNearByLocations;
    List<LocationAdder> nearbyLocationList;


    tempListNearByLocations = (await _dbHelper.getLocationWithFilter(myLatitudeLw, myLatitudeUp, myLongitudeLw, myLongitudeUp))!.cast<LocationAdder>();


    nearbyLocationList = tempListNearByLocations;

    if (tempListNearByLocations == null) {
      print('INSIDE NULL TABLE');

      double myLatitudeUpN = currentLocation.latitude + locationLimitBig;
      double myLatitudeLwN = currentLocation.latitude - locationLimitBig;
      double myLongitudeUpN = currentLocation.longitude + locationLimitBig;
      double myLongitudeLwN = currentLocation.longitude - locationLimitBig;

      //List<LocationAdder> tempListNearByLocationsN = await _dbHelper.getLocationWithFilterAndRegion(myLatitudeLwN, myLatitudeUpN, myLongitudeLwN, myLongitudeUpN,regionCode);
      List<LocationAdder>? tempListNearByLocationsN = [];


        tempListNearByLocationsN = (await _dbHelper.getLocationWithFilter(myLatitudeLwN, myLatitudeUpN, myLongitudeLwN, myLongitudeUpN))!.cast<LocationAdder>();
      if (tempListNearByLocationsN != null &&
          tempListNearByLocationsN.length > 0) {
        //nearbyLocationList = tempListNearByLocationsN;

        if (baseName == "" || baseName == "No Nearby Location Found") {
          print('first half');
          if (!mounted) return;
          setState(() {
            //isOutOfRange = true;
            print("helloworld");
          });
          //nearbyLocationList = tempListNearByLocationsN;
        }
        print('NOT NULL IF STATEMENT');
        //_repaint.value++;
      } else {
        print('second half');
        if (!mounted) return;
        setState(() {
          baseName = "No Nearby Location Found";
          //isOutOfRange = true;
          //_repaint.value++;
        });
      }
    }

    if (nearbyLocationList != null) {
      if (!mounted) return;
      setState(() {
        //isOutOfRange = false;
      });
      if (nearbyLocationList.isNotEmpty) {
        for (int i = 0; i < nearbyLocationList.length; i++) {
          meters = distanceCalculator(
              LatLng(currentLocation.latitude, currentLocation.longitude),
              LatLng(nearbyLocationList[i].latitude,
                  nearbyLocationList[i].longitude)) as double;

          if (i == 0) {
            print('Inside LOOP i==0');
            distanceNearbyLocation = meters;
          }

          if (distanceNearbyLocation >= meters) {
            print('Inside LOOP comparer');
            distanceNearbyLocation = meters;
            distanceNearbyLocationID = nearbyLocationList[i].id;
            distanceNearbyLocationName = nearbyLocationList[i].name;
            //baseLat = _locationadderList[i].latitude;
            //baseLong = _locationadderList[i].longitude;
          }
          await _setBaseLocation(
              distanceNearbyLocationID, distanceNearbyLocationName, 1);
          /*_repaint.value++;
          print(_repaint);*/
          print('Inside LOOP Last Statement');

          //searchAdjacentSquares();
          //searchAdjacentSquares();
          //nextLocationFunc(distanceNearbyLocationID);
        }
        print('INSIDE NOT NULL PHASE1 ');
        //getNearestBaseSquare();
      }
    }
    searchAdjacentSquares();
  }

  searchAdjacentSquares() async {
    double metersAdjModule;
    distanceAdjSquareModule == null
        ? print('list is null')
        : distanceAdjSquareModule.clear();
    distanceAdjSquareToBase == null
        ? print('list is null')
        : distanceAdjSquareToBase.clear();
    distancePRINTINGPURPOSE == null
        ? print('list is null')
        : distancePRINTINGPURPOSE.clear();
    //nextLocationsAdjacentLocation == null? print('list is null'):nextLocationsAdjacentLocation.clear();

    if (distanceNearbyLocationID != distanceNearbyLocationIDVerifier) {
      //double metersAdjModule;

      adjacentLocationNEARBY = (await _dbHelper.getAdjacentLocationSpecific(distanceNearbyLocationID))!.cast<AdjacentLocation>();
      print(
          '---------------------------------------------------------adjacent location Module');
      print(adjacentLocationNEARBY);

      //print(nextLocationDetailListLength);
      if (adjacentLocationNEARBY != null && adjacentLocationNEARBY!.length > 0) {
        nextLocationDetailListLength = adjacentLocationNEARBY!.length;
        nextLocationDetailNEW == null
            ? print('list is null')
            : nextLocationDetailNEW.clear();
        //distanceAdjSquareModule == null? print('list is null'):distanceAdjSquareModule.clear();

        for (int i = 0; i < nextLocationDetailListLength; i++) {
          /*print('---------------------------------------------------------adjacentLocationNEARBY[i].end_name');
          print(adjacentLocationNEARBY[i].end_id);*/

          List<LocationAdder>? adjacentLocationInfo = (await _dbHelper
              .getLocationInfo(adjacentLocationNEARBY![i].end_name))!.cast<LocationAdder>();
          print('INSIDE ADJACENT LOCATION MODULE');
          print(adjacentLocationInfo![0]);
          nextLocationDetailNEW.add(adjacentLocationInfo[0]);
          //print(adjacentLocationNEARBY);
        }
      }

      //nextLocationFunc(distanceNearbyLocationID);
      if (adjacentLocationNEARBY != null) {
        distanceNearbyLocationIDVerifier = distanceNearbyLocationID;
      }
    }

//------------------------------------Calculating Distance with base module, runs once only
    //if(distanceNearbyLocationID != distanceNearbyLocationIDVerifier2){
    for (int i = 0; i < nextLocationDetailListLength; i++) {
      metersAdjModule = distanceCalculator(
          LatLng(baseLat, baseLong),
          LatLng(nextLocationDetailNEW[i].latitude,
              nextLocationDetailNEW[i].longitude)) as double;
      distanceAdjSquareToBase.add(metersAdjModule);
      //print(distanceAdjSquareToBase[i]);
    }
    print('distanceAdjSquareToBase');
    print(distanceAdjSquareToBase);

    /*if (distanceAdjSquareToBase.isNotEmpty) {
      distanceNearbyLocationIDVerifier2 = distanceNearbyLocationID;
      }
    //distanceNearbyLocationIDVerifier = distanceNearbyLocationID;
    }*/

    //------------------------------Calculating Distance with GPS
    for (int i = 0; i < nextLocationDetailListLength; i++) {
      metersAdjModule = distanceCalculator(
          LatLng(currentLocation.latitude, currentLocation.longitude),
          LatLng(nextLocationDetailNEW[i].latitude,
              nextLocationDetailNEW[i].longitude)) as double;
      distanceAdjSquareModule.add(metersAdjModule);
    }
    print('distanceAdjSquareModule');
    print(distanceAdjSquareModule);

    //-----------------------------Calculating the difference between these Lists

    double progressTowardsSquare = 0;
    double tempProgress = 0;
    int differenceID = -1;

    ///this loop is to identify max. progress towards the next adjacent square
    for (int i = 0; i < nextLocationDetailListLength; i++) {
      /*double x = distanceAdjSquareToBase[i] - distanceAdjSquareModule[i];
      tempProgress = x.abs();*/
      tempProgress = distanceAdjSquareToBase[i] - distanceAdjSquareModule[i];
      distancePRINTINGPURPOSE.add(tempProgress);

      //if(shouldNotExclude){
      if (nextLocationDetailListLength < 2) {
        if (lastBaseName == adjacentLocationNEARBY![i].end_name) {
          print('square skipped is' + lastBaseName);
          continue;
        }
      }
      //}

      if (i == 0) {
        progressTowardsSquare = tempProgress;
        differenceID = i;
      }

      if (progressTowardsSquare < tempProgress) {
        progressTowardsSquare = tempProgress;
        differenceID = i;
      }
    }

    print(
        '------------------------------------------------------------------------------');
    print(distancePRINTINGPURPOSE);
    print(
        '------------------------------------------------------------------------------');

    /*if(progressTowardsSquare > 41){
      shouldNotExclude = false;
      print('DISABLED THE SKIP MODULE');
    }else{
      shouldNotExclude = true;
      print('ENABLED THE SKIP MODULE');
    }*/

    if (progressTowardsSquare < 20) {
      //45
      //nextLocationNameGB = "Please move";
      //nextLocationsAdjacentLocation == null? print('list is null'):nextLocationsAdjacentLocation.clear();
      //nextLocationsAdjacentLocationLength = 0;
      //print('NAMASKAR');
      print(nextLocationNameGB);
    } else if (progressTowardsSquare > 19 && progressTowardsSquare < 45) {
      if (lastBaseName != adjacentLocationNEARBY![differenceID].end_name) {
        nextLocationNameGB = adjacentLocationNEARBY![differenceID].end_name;
        nextLocationIdGB = adjacentLocationNEARBY![differenceID].end_id;
        print(nextLocationNameGB);
        print(nextLocationIdGB);
      }
    } else {
      nextLocationNameGB = adjacentLocationNEARBY![differenceID].end_name;
      nextLocationIdGB = adjacentLocationNEARBY![differenceID].end_id;

      print(nextLocationNameGB);
      print(nextLocationIdGB);
    }

    print("//////////differenceID");
    print(differenceID);

    //nextLocationCalculator(distanceAdjSquareToBase,distanceAdjSquareModule);

    if (nearbyLocationVerifier != nextLocationIdGB) {
      if (nextLocationNameGB != null && nextLocationIdGB != null) {
        setState(() {
          speedNumber = adjacentLocationNEARBY![differenceID].speed_limit;


          //speedNumber = adjacentLocationNEARBY[differenceID].speed_limit;
          speedLimitForColor = speedNumber;
          currentPML = adjacentLocationNEARBY![differenceID].permissible_speed; //ADMIN PML
          int tempPermissibleSpeedLimitA = 0;

          if (currentPML == -1) {
            tempPermissibleSpeedLimitA = usersCustomPML;
            print("Printing when no permissible speed limit is set & usersCustomPML = $usersCustomPML");
          } else {
            tempPermissibleSpeedLimitA = currentPML;
            print("Printing when permissible speed limit is set & currentPML = $currentPML");
            if (usersCustomPML >= currentPML) {
              tempPermissibleSpeedLimitA = 0;
              tempPermissibleSpeedLimitA = usersCustomPML;
              print("Printing when permissible speed limit is set userCPML> APML & usersCustomPML = $usersCustomPML");
            }
          }
          print(
              '////////////////////////////tempPermissibleSpeedLimitA = $tempPermissibleSpeedLimitA');
          print('////////////////////////////speedNumber = $speedNumber');
          if (tempPermissibleSpeedLimitA > 0) {
            totalPML = (speedNumber * (1 + (tempPermissibleSpeedLimitA / 100))).toInt();
            print('Upper loop of formula');
          } else {
            totalPML = speedNumber.toInt();
            print('Lower loop of formula');
          }
          print('////////////////////////////totalPML = $totalPML');
        });

        //specialLocationAlert();

        nextLocationsAdjacentLocation == null
            ? print('list is null')
            : nextLocationsAdjacentLocation.clear();
        nextLocationSpeedLimit == null
            ? print('list is null')
            : nextLocationSpeedLimit.clear();
        nextLocationPermissibleSpeedLimit == null
            ? print('list is null')
            : nextLocationPermissibleSpeedLimit.clear();

        List<AdjacentLocation> tempListNL =
        (await _dbHelper.getAdjacentLocationSpecific(nextLocationIdGB))!.cast<AdjacentLocation>();
        nextLocationsAdjacentLocation = tempListNL;
        nextLocationsAdjacentLocationLength = tempListNL.length;

        //angleCalculator(nextLocationIdGB);

        if (nextLocationsAdjacentLocation != null) {
          for (int i = 0; i < nextLocationsAdjacentLocationLength; i++) {
            nextLocationSpeedLimit
                .add(nextLocationsAdjacentLocation[i].speed_limit);
          }
          nearbyLocationVerifier = nextLocationIdGB;
        }

        /*if (nextLocationsAdjacentLocation != null) {
          nearbyLocationVerifier = nextLocationIdGB;
        }*/
      }
    }
  }

  _setBaseLocation(int iD, String name, int parameter) async {
    if (parameter == 1) {
      List<LocationAdder> tempList = (await _dbHelper.getLocationInfo(name))!.cast<LocationAdder>();
      baseLong = tempList[0].longitude;
      baseLat = tempList[0].latitude;
      baseId = tempList[0].id;

      if (baseName != tempList[0].name) {
        lastBaseName = baseName;
      }

      baseName = tempList[0].name;
    } else {
      baseName = name;
    }
  }

}


