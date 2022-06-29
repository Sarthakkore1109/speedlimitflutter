class AdjacentLocation {
/*  static const tblAdjacentLocationadder = 'adjacentlocations';
  static const colId = 'id';
  static const colSName = 'start_name';
  static const colSLongitude = 'start_longitude';
  static const colSLatitude = 'start_latitude';
  static const colEName = 'end_name';
  static const colELongitude = 'end_longitude';
  static const colELatitude = 'end_latitude';
  static const colSpeedLimit = 'speed_limit';

  AdjacentLocation({
    this.start_name,
    this.start_longitude,
    this.start_latitude,
    this.end_name,
    this.end_longitude,
    this.end_latitude,
    this.speed_limit
  });

  AdjacentLocation.fromMap(Map<String,dynamic> map){
    id = map[colId];
    start_name = map[colSName];
    start_longitude = map[colSLongitude];
    start_latitude = map[colSLatitude];
    end_name = map[colEName];
    end_longitude = map[colELongitude];
    end_latitude = map[colELatitude];
    speed_limit = map[colSpeedLimit];
  }

  int id;
  String start_name;
  String start_longitude;
  String start_latitude;
  String end_name;
  String end_longitude;
  String end_latitude;
  String speed_limit;

Map<String,dynamic> toMap(){
  var map = <String,dynamic>{
    colSName: start_name,
    colSLongitude: start_longitude,
    colSLatitude:start_latitude,
    colEName: end_name,
    colELongitude: end_longitude,
    colELatitude: end_latitude,
    colSpeedLimit: speed_limit,
  };
  if(id!=null) map[colId] = id;
  return map;
}*/

  static const tblAdjacentLocationadder = 'adjacentlocations';
  static const colId = 'id';
  static const colSName = 'start_name';
  static const colSId = 'start_id';
  static const colEName = 'end_name';
  static const colEId = 'end_Id';
  static const colSpeedLimit = 'speed_limit';
  static const colSpecialLocation = 'special_location';
  static const colPermissibleSpeed = 'permissible_speed';

  /*AdjacentLocation.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    start_name = map[colSName];
    start_id = map[colSId];
    end_name = map[colEName];
    end_id = map[colEId];
    speed_limit = map[colSpeedLimit];
  }
*/
  AdjacentLocation({this.id = 0,this.start_name = '',this.start_id = 0, this.end_name = '', this.end_id = 0,  this.speed_limit= 0, this.special_location = 1, this.permissible_speed = 0});

  int id;
  String start_name;
  int start_id;
  String end_name;
  int end_id;
  double speed_limit;
  int special_location;
  int permissible_speed;

  /*Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colSName: start_name,
      colSId: start_id,
      colEName: end_name,
      colEId: end_id,
      colSpeedLimit: speed_limit,
    };
    if (id != null) map[colId] = id;
    return map;
  }*/

  factory AdjacentLocation.fromJson(Map<dynamic,dynamic> json)=>new AdjacentLocation(
    id: json["id"],
    start_name: json["start_name"],
    start_id: json["start_id"],
    end_name: json["end_name"],
    end_id: json["end_Id"],
    speed_limit: json["speed_limit"],
    special_location: json["special_location"],
    permissible_speed: json["permissible_speed"]
  );

  Map<String, dynamic> toJson()=> {

    "id": id,
    "start_id": start_id,
    "start_name": start_name,
    "end_id": end_id,
    "end_name": end_name,
    "speed_limit": speed_limit,
    "special_location":special_location,
    "permissible_speed":permissible_speed,

    if (id != null) "id": id,

  };


}
