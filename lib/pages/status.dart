import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_names/services/socket_service.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  //final data = { 'nombre': 'Flutter', mensaje: 'Hola desde Flutter'};

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Server status: ${ socketService.serverStatus }'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: (){
          socketService.socket.emit('nuevo-mensaje', { 
            'nombre': 'Flutter', 
            'mensaje': 'Hola desde Flutter'
          });

          /* socketService.emit('nuevo-mensaje', { 
            'nombre': 'Flutter', 
            'mensaje': 'Hola desde Flutter'
          }); */
        }
      ),
    );
  }
}
