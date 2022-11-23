
// ignore_for_file: no_logic_in_create_state

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class HorarioScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _HorarioScreenState();
}


class _HorarioScreenState extends State<HorarioScreen> {
  dynamic bd;
  String horarios = "";
  
  Future<void> readJson() async {
    final String response = 
          await rootBundle.loadString('assets/horarios.json');
    bd = await json.decode(response);
    print(bd[1]['linha']);
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
                horarios = "";
                
                for(int i = 0; i < bd[indice]['ida']['horarios']['diaUtil'].length; i++){
                  horarios += bd[indice]['ida']['horarios']['diaUtil'][i]['partida'].toString() + "  ";
                }
                print(horarios);
                setState(() {
                  
                });
              },
              icon: Icon(Icons.search),
              iconSize: 40,
            ),
          )
          
        ],),

        Row(children: [

          Padding(
            padding: EdgeInsets.all(50),
            child: Container(
              width: 320,
              //child: Flexible(
                child: Text( 
                  '$horarios',
                  style: const TextStyle(color: Colors.black, fontSize: 15,)
                )
              //),
            )
          )
          
          
        ],)
      ],)
    );
  }

  
}
