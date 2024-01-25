import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;


enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier{

  ServerStatus _serverStatus = ServerStatus.connecting;

  get serverStatus => _serverStatus;

  SocketService() {
    _initConfig();
  }


  void _initConfig() {
    
    // Dart client
    IO.Socket socket = IO.io('http://192.168.0.223:3000/', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    socket.on('connect', (_) {
      print('connect');
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    socket.on('disconnect', (_) {
      print('disconnect');
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    socket.on('nuevo-mensaje', ( payload ) {
      print('new message: $payload');
      print('new message:' + payload['nombre']);
      print('new message:' + payload['mensaje']);
      print( payload.containsKey('mensaje2') ? payload['mensaje2'] : ' no hay' );


    });

  }

}