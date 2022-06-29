class DatabaseVersionControl{
  static const tblDatabaseAdder = 'database_version';
  static const colId = 'id';
  static const colType = 'name';

  DatabaseVersionControl({required this.id,required this.name});

  int id;
  String name;

  factory DatabaseVersionControl.fromJson(Map<String,dynamic> json)=> new DatabaseVersionControl(
    id: json["id"],
    name: json["name"],
  );

  Map<String,dynamic> toJson()=>{
    "name": name,

    if(id != null) "id":id,
  };
}