class LocationAdder{
  static const tblLocationadder = 'locations';
  static const colId = 'id';
  static const colName = 'name';
  static const colLongitude = 'longitude';
  static const colLatitude = 'latitude';
  static const colRegion = 'region';

  LocationAdder({this.id = 0,this.name = '',this.longitude = 0,this.latitude = 0,this.region = 1});

  /*LocationAdder.fromMap(Map<String,dynamic> map){
    id = map[colId];
    name = map[colName];
    longitude = map[colLongitude];
    latitude = map[colLatitude];

  }*/

  int id;
  String name;
  double longitude;
  double latitude;
  int region;

  /*Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      colName:name,
      colLongitude:longitude,
      colLatitude:latitude
    };
    if(id!=null) map[colId] = id;
    return map;
  }*/

  factory LocationAdder.fromJson(Map<dynamic,dynamic> json)=> new LocationAdder(
      id: json["id"],
      name: json["name"],
      longitude: json["longitude"],
      latitude: json["latitude"],
      region:  json["region"]
  );

  Map<String,dynamic> toJson()=>{
    "name": name,
    "longitude": longitude,
    "latitude": latitude,
    "region" : region,

    if(id != null) "id":id,
  };

}