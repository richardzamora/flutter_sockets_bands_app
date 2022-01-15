import 'package:flutter/material.dart';
import 'package:flutter_sockets_bands_app/src/services/socket_service.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    socketService.socket.on('emitir-mensaje', (payload) {
      payload as Map;
      print("nuevo-mensaje:");
      if (payload.containsKey('nombre')) print("nombre " + payload['nombre']);
      if (payload.containsKey('mensaje'))
        print("mensaje ${payload['mensaje']}");
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('ServerStatus: ${socketService.serverStatus}')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          socketService.socket.emit("emitir-mensaje",
              {"nombre": "Flutter", "mensaje": "Hola desde Flutter"});
        },
      ),
    );
  }
}
