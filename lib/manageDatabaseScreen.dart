import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:speedlimitflutter/util/databasehelper.dart';

class ManageDatabase extends StatefulWidget {
  @override
  _ManageDatabaseState createState() => _ManageDatabaseState();
}

class _ManageDatabaseState extends State<ManageDatabase> {
  late DatabaseHelper _dbHelper;
  bool isPressedExport = false;
  bool isPressedImport = false;

  void initState() {
    super.initState();

    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    initializeDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instructions for managing Database'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'All the necessary files will be backed up by clicking on Export Button .\n\n(This is the path : Android/Data/com.be.aware/files/)\n\n\nFor taking backup, just make a copy of all the file(s) present in this \'files\' folder to somewhere else.\n\nFor restoring the database, just paste the copy of database you made, in the same \'files\' folder.\n\n ',
                maxLines: null,
                style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
            ),
            RaisedButton(
              onPressed: () {
                exportData();
              },
              child: Text('Export'),
            ),
            RaisedButton(
              onPressed: () async {
                setState(() {
                  isPressedImport = true;
                });
                importData();
              },
              child: Text('Import'),
            )
          ],
        ),
      ),
    );
  }

  //TODO: Replace all flushbars success colors with green

  exportData() async {
    bool? message = await _dbHelper.exportDatabase();
    String checker = message.toString();
    if (checker == "true") {
      Flushbar(
        title: "Status",
        message: "Data Exported successfully",
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      Flushbar(
        title: "Warning",
        backgroundColor: Colors.redAccent,
        message: "Failed to export Data",
        duration: Duration(seconds: 3),
      )..show(context);
    }
    setState(() {
      isPressedExport = false;
    });
    print(message);
  }

  importData() async {
    bool message = await _dbHelper.importDatabase();
    String dataReturn = message.toString();
    if (dataReturn == "true") {
      Flushbar(
        title: "Status",
        message: "Data Imported Successfully",
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      Flushbar(
        title: "Warning",
        backgroundColor: Colors.redAccent,
        message: "Failed to import data",
        duration: Duration(seconds: 3),
      )..show(context);
    }

    setState(() {
      isPressedImport = false;
    });
    print(message);
  }

  initializeDB() async {
    int starter = await _dbHelper.initializingDatabase();
    print(starter);
  }
}
