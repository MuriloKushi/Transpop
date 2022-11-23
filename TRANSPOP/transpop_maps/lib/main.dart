// ignore_for_file: non_constant_identifier_names, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:transpop_maps/Location_service.dart';

import 'horarios_screen.dart';
import 'compartilhar_local.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transpop',
      home: MapSample(),
      
    );
  }
}
dynamic bd;
Future<void> readJson() async {
    final String response = 
          await rootBundle.loadString('assets/pontos.json');
    bd = await json.decode(response);
    print(bd[1]['linha']);
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition posInicial = CameraPosition(
    //target: LatLng(-22.909050506715424, -47.062290605775075),
    
    target: LatLng(-22.85167827902673, -47.06021849871605),
    zoom: 17,
  );


  final String key = "AIzaSyBq0NKILfZN4ECKy8kPp6wT-Jogkg_R5JU";
  List<LatLng> polylineCoordinates = [];
  final Set<Polyline>_polyline={};
  final myController = TextEditingController();
  LocationData? currentLocation;
  String sentido = 'Sentido da linha';
  bool ida = true;
  int linhaAtual = -1;
  bool _isButtonEnabled = true;
  final Set<Marker> markers = new Set();
  late BitmapDescriptor image;

  
 

  void  getCurrentLocation() async{
    Location location = new Location();

    image = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 10), "assets/icon.png");

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentLocation = await location.getLocation();
    print(currentLocation); ///////localizacao

    if(currentLocation == null){
      return;
    }

    //final GoogleMapController controller = await _controller.future;
    //controller.animateCamera(CameraUpdate.newCameraPosition(
    //  CameraPosition(target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!), zoom: 15)
    //));

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
      body: GoogleMap(
        markers:markers,
        polylines: {
          Polyline(polylineId: PolylineId("rota"),
          points: polylineCoordinates,
          color: Colors.deepPurple,
          width: 5)
        },
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        initialCameraPosition: posInicial,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          getCurrentLocation();
          readJson();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
                showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      //String lat, lon;
                      //List<String> latlon;
                      return Container(
                        height: 250,
                        color: Colors.white,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: TextFormField(
                                    controller: myController,
                                    decoration: const InputDecoration(
                                    icon: Icon(Icons.bus_alert_outlined),//{'linha':'333','lat':'-23.000','lon':'47.16241071922904'}  38   LocationData<lat: 37.33233141, long: -122.0312186>


                                      hintText: 'Número da linha',
                                      labelText: 'Linha',
                                    ),
                                  ),
                                )),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: ElevatedButton(
                                            child: const Text('Confirmar'),
                                            onPressed: () async {



                                              String local = "";

                                              

                                              

                                              ida = true;

                                              String linha = myController.text;
                                              //myController.clear();
                                              int indice = -1;
                                              Navigator.pop(context);

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

                                              await LocalStorage().readCounter().then((value) => local = value);


                                              dynamic x = jsonDecode(local);

                                              print(x);

                                             

                                              print(x[indice]['lat']);
                                              print(x[indice]['lon']);
                                              markers.clear();

                                              final GoogleMapController controller = await _controller.future;
                                              controller.animateCamera(CameraUpdate.newCameraPosition(
                                                CameraPosition(target: LatLng(double.parse(bd[indice]['ida']['paradas'][0]['lat']), double.parse(bd[indice]['ida']['paradas'][0]['lon'])), zoom: 15)
                                              ));

                                              if(linhaAtual != indice){
                                                polylineCoordinates.clear();
                                                

                                                markers.add(Marker( //add first marker
                                                  markerId: MarkerId(LatLng(double.parse(bd[indice]['ida']['paradas'][0]['lat']), double.parse(bd[indice]['ida']['paradas'][0]['lon'])).toString()),
                                                  position: LatLng(double.parse(bd[indice]['ida']['paradas'][0]['lat']), double.parse(bd[indice]['ida']['paradas'][0]['lon'])), //position of marker
                                                  
                                                  
                                                  infoWindow: InfoWindow( //popup info 
                                                    title: 'Ponto $indice',
                                                    snippet: bd[indice]['ida']['paradas'][0]['lat']+" ," + bd[indice]['ida']['paradas'][0]['lon']
                                                  ),
                                                  icon: image, //Icon for Marker
                                                ));

                                                markers.add(Marker( //add first marker
                                                  markerId: MarkerId("Localização do ônibus"),
                                                  position: LatLng(double.parse(x[indice]['lat']), double.parse(x[indice]['lon'])), //position of marker
                                                  
                                                  
                                                  infoWindow: InfoWindow( //popup info 
                                                    title: '333',
                                                    snippet: "localizacao"
                                                  ),
                                                  icon: image, //Icon for Marker
                                                ));
                                              
                                            
                                                for(int i = 0; i < bd[indice]['ida']['paradas'].length-1; i++){

                                                  print(bd[indice]['ida']['paradas'].length);

                                                  int x = i+2;
                                                  markers.add(Marker( //add first marker
                                                  markerId: MarkerId(LatLng(double.parse(bd[indice]['ida']['paradas'][i+1]['lat']), double.parse(bd[indice]['ida']['paradas'][i+1]['lon'])).toString()),
                                                  position: LatLng(double.parse(bd[indice]['ida']['paradas'][i+1]['lat']), double.parse(bd[indice]['ida']['paradas'][i+1]['lon'])), //position of marker
                                                  
                                                  infoWindow: InfoWindow( //popup info 
                                                    title: 'Ponto $x',
                                                    snippet: bd[indice]['ida']['paradas'][i+1]['lat']+" ," + bd[indice]['ida']['paradas'][i+1]['lon']
                                                  ),
                                                  icon: image, //Icon for Marker
                                                ));

                                                  PolylinePoints polylinePoints = PolylinePoints();

                                                  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
                                                    key, 
                                                    PointLatLng(double.parse(bd[indice]['ida']['paradas'][i]['lat']), double.parse(bd[indice]['ida']['paradas'][i]['lon'])),
                                                    PointLatLng(double.parse(bd[indice]['ida']['paradas'][i+1]['lat']), double.parse(bd[indice]['ida']['paradas'][i+1]['lon'])),
                                                  );
                                                  

                                                  if(result.points.isNotEmpty){
                                                    result.points.forEach((PointLatLng point) => polylineCoordinates.add(LatLng(point.latitude, point.longitude))

                                                    );
                                                    setState(() {});

                                                  }


                                                }
                                                setState(() {
                                                    sentido = bd[indice]['ida']['sentido'];

                                                  });
                                                  linhaAtual = indice;
                                                  polylineCoordinates = [];

                                              }

                                            },
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            textStyle:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                      ],
                                    ))),
                          ],
                        ),
                        //),
                      );
                    },
                  );
                }, //_goToTheLake,
        label: Text('Linhas'),
        icon: Icon(Icons.search),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButtonLocation: 
      FloatingActionButtonLocation.endDocked,
      drawer: Drawer(
        child: Container(
          color: Colors.white,
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
             DrawerHeader(

              decoration: BoxDecoration(
                color: Colors.deepPurple,
                
              ),
              child: 
              Padding(
                padding: EdgeInsets.fromLTRB(10,10,10,10),
                child: Wrap(

                    children: [
                      Icon(Icons.location_city, color: Colors.white, size: 25,),
                    Text("Transpop", style: TextStyle(color: Colors.white, fontSize: 25),)
                  ],
                ),
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20,20,20,20),
              child: FloatingActionButton.extended(
                label:Text("Pesquisar linhas"),
                icon: Icon(Icons.search),
                backgroundColor: Colors.grey,
                onPressed: (() => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HorarioScreen())
            ))
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20,20,20,20),
              child: FloatingActionButton.extended(
                label:Text("Compartilhar local"),
                icon: Icon(Icons.location_history),
                backgroundColor: Colors.deepPurple,
                onPressed: (() => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => LocalScreen(storage: LocalStorage()))
            ))
              ),
            ),
          ],
        ),
      )),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        shape: AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(0),
            ),
          ),
          RoundedRectangleBorder(borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),)
        ),
        color: Color.fromARGB(204, 64, 167, 61),
      child:  Row(
        mainAxisSize: MainAxisSize.max,
        children: 
            [Padding(padding: EdgeInsets.fromLTRB(10, 5, 0, 0),child: IconButton(iconSize: 30,color: Colors.white,icon: Icon(Icons.cached), onPressed: _isButtonEnabled?() async 
            
            {
              _isButtonEnabled = false;
              polylineCoordinates.clear();
              markers.clear();

              if(linhaAtual >= 0){
                if(ida == true){
                setState(() {
                  sentido = bd[linhaAtual]['volta']['sentido'];
                  ida = false;
                });
                  markers.add(Marker( //add first marker
                    markerId: MarkerId(LatLng(double.parse(bd[linhaAtual]['volta']['paradas'][0]['lat']), double.parse(bd[linhaAtual]['volta']['paradas'][0]['lon'])).toString()),
                    position: LatLng(double.parse(bd[linhaAtual]['volta']['paradas'][0]['lat']), double.parse(bd[linhaAtual]['volta']['paradas'][0]['lon'])), //position of marker

                    infoWindow: InfoWindow( //popup info 
                      title: 'Ponto 1',
                      snippet: bd[linhaAtual]['volta']['paradas'][0]['lat']+" ," + bd[linhaAtual]['volta']['paradas'][0]['lon']
                    ),
                    icon: image, //Icon for Marker
                  ));

                //final GoogleMapController controller = await _controller.future;
                //controller.animateCamera(CameraUpdate.newCameraPosition(
                //  CameraPosition(target: LatLng(double.parse(bd[linhaAtual]['volta']['paradas'][0]['lat']), double.parse(bd[linhaAtual]['volta']['paradas'][0]['lon'])), zoom: 15)
                //));
                for(int i = 0; i < bd[linhaAtual]['volta']['paradas'].length-1; i++){
                  

                  int x = i+1;
                  markers.add(Marker( //add first marker
                    markerId: MarkerId(LatLng(double.parse(bd[linhaAtual]['volta']['paradas'][i]['lat']), double.parse(bd[linhaAtual]['volta']['paradas'][i]['lon'])).toString()),
                    position: LatLng(double.parse(bd[linhaAtual]['volta']['paradas'][i]['lat']), double.parse(bd[linhaAtual]['volta']['paradas'][i]['lon'])), //position of marker

                    infoWindow: InfoWindow( //popup info 
                      title: 'Ponto $x',
                      snippet: bd[linhaAtual]['volta']['paradas'][i+1]['lat']+" ," + bd[linhaAtual]['volta']['paradas'][i+1]['lon']
                    ),
                    icon: image, //Icon for Marker
                  ));

                  PolylinePoints polylinePoints = PolylinePoints();

                  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
                    key, 
                    PointLatLng(double.parse(bd[linhaAtual]['volta']['paradas'][i]['lat']), double.parse(bd[linhaAtual]['volta']['paradas'][i]['lon'])),
                    PointLatLng(double.parse(bd[linhaAtual]['volta']['paradas'][i+1]['lat']), double.parse(bd[linhaAtual]['volta']['paradas'][i+1]['lon'])),
                  );

                  if(result.points.isNotEmpty){
                    result.points.forEach((PointLatLng point) => polylineCoordinates.add(LatLng(point.latitude, point.longitude))
                    );
                    setState(() {});
                  }                        
                }
              }
              else if(ida == false){
                setState(() {
                  sentido = bd[linhaAtual]['ida']['sentido'];
                  ida = true;
                });

                markers.add(Marker( //add first marker
                    markerId: MarkerId(LatLng(double.parse(bd[linhaAtual]['ida']['paradas'][0]['lat']), double.parse(bd[linhaAtual]['ida']['paradas'][0]['lon'])).toString()),
                    position: LatLng(double.parse(bd[linhaAtual]['ida']['paradas'][0]['lat']), double.parse(bd[linhaAtual]['ida']['paradas'][0]['lon'])), //position of marker

                    infoWindow: InfoWindow( //popup info 
                      title: 'Ponto 1',
                      snippet: bd[linhaAtual]['ida']['paradas'][0]['lat']+" ," + bd[linhaAtual]['ida']['paradas'][0]['lon']
                    ),
                    icon: image, //Icon for Marker
                  ));
                //final GoogleMapController controller = await _controller.future;
                //controller.animateCamera(CameraUpdate.newCameraPosition(
                //  CameraPosition(target: LatLng(double.parse(bd[linhaAtual]['ida']['paradas'][0]['lat']), double.parse(bd[linhaAtual]['ida']['paradas'][0]['lon'])), zoom: 15)
                //));
                for(int i = 0; i < bd[linhaAtual]['ida']['paradas'].length-1; i++){

                  int x = i+2;
                  markers.add(Marker( //add first marker
                    markerId: MarkerId(LatLng(double.parse(bd[linhaAtual]['ida']['paradas'][i]['lat']), double.parse(bd[linhaAtual]['ida']['paradas'][i+1]['lon'])).toString()),
                    position: LatLng(double.parse(bd[linhaAtual]['ida']['paradas'][i]['lat']), double.parse(bd[linhaAtual]['ida']['paradas'][i+1]['lon'])), //position of marker

                    infoWindow: InfoWindow( //popup info 
                      title: 'Ponto $x',
                      snippet: bd[linhaAtual]['ida']['paradas'][i+1]['lat']+" ," + bd[linhaAtual]['ida']['paradas'][i+1]['lon']
                    ),
                    icon: image, //Icon for Marker
                  ));

                  PolylinePoints polylinePoints = PolylinePoints();

                  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
                    key, 
                    PointLatLng(double.parse(bd[linhaAtual]['ida']['paradas'][i]['lat']), double.parse(bd[linhaAtual]['ida']['paradas'][i]['lon'])),
                    PointLatLng(double.parse(bd[linhaAtual]['ida']['paradas'][i+1]['lat']), double.parse(bd[linhaAtual]['ida']['paradas'][i+1]['lon'])),
                  );

                  if(result.points.isNotEmpty){
                    result.points.forEach((PointLatLng point) => polylineCoordinates.add(LatLng(point.latitude, point.longitude))
                    );
                    setState(() {});
                  }                        
                }
              }
              }
              _isButtonEnabled = true;
            } : null,
            
            
            
            ),), 
            Text( '$sentido',
            maxLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 15,)
            )
          ],
        
      ),
    ),
    );
  }

  Future<void> _irParaLugar(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lon = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lon), zoom: 15)
    ));
  }

  //Future<void> goToLocation(LocationData data) async {
  //  //double lat = data.latitude;
  //  //double lon = data.longitude;
//
  //  final GoogleMapController controller = await _controller.future;
  //  controller.animateCamera(CameraUpdate.newCameraPosition(
  //    CameraPosition(target: LatLng(lat!, lon!), zoom: 15)
  //  ));
  //}
}