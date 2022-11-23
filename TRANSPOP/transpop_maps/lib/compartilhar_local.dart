
// ignore_for_file: no_logic_in_create_state

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_linhas.json');
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();
      print(contents);

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "EEEEEEEEE";
    }
  }

  Future<File> writeCounter(String counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}

class LocalScreen extends StatefulWidget{
  const LocalScreen({required this.storage});

  final LocalStorage storage;

  @override
  State<StatefulWidget> createState() => _LocalScreenState();
}


class _LocalScreenState extends State<LocalScreen> {
  String jsonData = "";
  dynamic bd;
  String horarios = "";
  Location location = new Location();
  bool compartilhando = false;
  
  Future<void> readJson() async {
    final String response = 
          await rootBundle.loadString('assets/local_linhas.json');
    bd = await json.decode(response);
    print(bd[1]['linha']);
}

Future<File> _incrementCounter() {
    
    // Write the variable as a string to the file.
    return widget.storage.writeCounter(jsonData);
  }

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/local_linhas.json');
}


  String linha = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: DropdownButton(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Wrap(
          children: [
            Icon(Icons.location_city),
            Text("Transpop")
          ],),
        centerTitle: true,
      ),
      body: 
      Column(children: [
        Row(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(100,40,0,0),
            child: SizedBox(
              width: 200,
              child: TextField(
                onChanged:(value) {
                  linha = value;
                  print(linha);
                },
                maxLength: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Número da linha',
                ),
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0,20,0,0),
            child: IconButton(
              onPressed: () async {
                if(bd == null){
                  await readJson();
                }
                
                int indice = -1;
                for(int i = 0; i < bd.length; i++){
                  if(bd[i]['linha'] == linha){
                    indice = i;
                    break;
                  }
                }
                if (indice < 0){
                  print("Linha inexistente");
                  return;
                }

                compartilhando = true;
                
                for(;;){
                  if(compartilhando == false){
                    break;
                  }
                  sleep(Duration(seconds:2));

                  
                  LocationData? currentLocation;
                  currentLocation = await location.getLocation();
                  print(currentLocation);
                  
                  
                  bd[indice]['lat'] = currentLocation.latitude.toString();
                  bd[indice]['lon'] = currentLocation.longitude.toString();

                  jsonData = jsonEncode(bd);

                  
                  _incrementCounter();

                }
              },
              icon: Icon(Icons.ios_share),
              iconSize: 40,
            ),
          )
          
        ],),
        Row(children: [

          Padding(
            padding: EdgeInsets.all(50),
            child: Container(
              width: 300,
              //child: Flexible(
                child: FloatingActionButton.extended( 
                  label: Text('Parar compartilhamento'),
                  onPressed:(){
                    if(compartilhando == true){
                      compartilhando = false;
                    }
                  },
                  
                )
              //),
            )
          )
          
          
        ],)
      ],)
    );
  }

  
}
