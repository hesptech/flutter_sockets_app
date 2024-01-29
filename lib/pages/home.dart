import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import '../models/band.dart';
import '../services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    /* Band(id: '1', name: 'Metallica', votes: 3),
    Band(id: '2', name: 'Queen', votes: 2),
    Band(id: '3', name: 'Heroes', votes: 4),
    Band(id: '4', name: 'Ban jovi', votes: 5) */
  ];


  @override
  void initState() {
    final socketService =  Provider.of<SocketService>(context, listen: false);

    /* socketService.socket.on('active-bands', ( payload ) {
      bands = (payload as List)
        .map( (band) => Band.fromMap(band) )
        .toList();
      setState(() {});
      //print( payload );
    }); */

    socketService.socket.on('active-bands', _handleActiveBands );

    super.initState();
  }


  _handleActiveBands( dynamic payload ) {
    bands = (payload as List)
      .map( (band) => Band.fromMap(band) )
      .toList();

    setState(() {});
  }


  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    //final bool socketOn = socketService.serverStatus == ServerStatus.online ? true : false ;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle( color: Colors.black87 ) ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only( right: 10.0 ),
            child: socketService.serverStatus == ServerStatus.online 
            ? Icon(Icons.check_circle, color: Colors.blue[300]) 
            : const Icon(Icons.offline_bolt, color: Colors.red,)
          )
        ],
      ),
      body: Column(
        children: [

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( context, i ) => _bandTile(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: addNewBand,
        child: const Icon( Icons.add )
      ),
    );
  }

  Widget _bandTile( Band band ) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) {
        //print('direction: $direction');
        //print('id: ${ band.id }');

      socketService.socket.emit('delete-band', {'id': band.id} );
      // or
      //socketService.emit('delete-band', {'id': band.id});
      
      // nO!!
      //setState(() {});
      },
      background: Container(
        padding: const EdgeInsets.only( left: 8.0 ),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle( color: Colors.white) ),
        )
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text( band.name.substring(0,2) ),
        ),
        title: Text( band.name ),
        trailing: Text('${ band.votes }', style: const TextStyle( fontSize: 20) ),
        onTap: () {
          //print(band.name);
          socketService.socket.emit('vote-band', {'id': band.id} );
        },
      ),
    );
  }


  addNewBand() {

    final textController = TextEditingController();
    
    if ( Platform.isAndroid ) {
      // Android
      return showDialog(
        context: context,
        builder: ( context ) {
          return AlertDialog(
            title: const Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList( textController.text ),
                child: const Text('Add')
              )
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: ( _ ) {
        return CupertinoAlertDialog(
          title: const Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToList( textController.text )
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        );
      }
    );

  }  

  void addBandToList( String name ) {
    //print(name);
    final socketService = Provider.of<SocketService>(context, listen: false);

    if ( name.length > 1 ) {
      // Podemos agregar
      //bands.add( Band(id: DateTime.now().toString(), name: name, votes: 0 ) );

      socketService.socket.emit('add-band', {'name': name} );
      // or ....
      // socketService.emit('add-band', {'name': name});

      setState(() {});
    }


    Navigator.pop(context);

  }


  Widget _showGraph() {

    //Map<String, double> dataMap = new Map();
    //dataMap.putIfAbsent('Band name', () => 5);

    Map<String, double> dataMap = {
      /* "Flutter": 5,
      "React": 3,
      "Xamarin": 2,
      "Ionic": 2, */
    };

    /* bands.forEach((band) {
      dataMap.putIfAbsent( band.name, () => band.votes.toDouble()); 
    }); */

    // instaed of forEach a for loop....
    for (var band in bands) {
      dataMap.putIfAbsent( band.name, () => band.votes.toDouble()); 
    }

    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        chartValuesOptions: const ChartValuesOptions(showChartValuesInPercentage: true),
        chartType: ChartType.ring,
      )
    );
  }


}