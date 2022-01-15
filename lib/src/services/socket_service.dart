import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;

  IO.Socket _socket;

  IO.Socket get socket => _socket;

  SocketService() {
    _initConfig();
  }

  get serverStatus => _serverStatus;

  void _initConfig() {
    _socket = IO.io(
      'http://192.168.20.57:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );
    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    // socket.on('mensaje', (data) => print("mensaje " + data));
    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // _socket.on('nuevo-mensaje', (payload) {
    //   payload as Map;
    //   print("nuevo-mensaje:");
    //   print("nombre " + payload['nombre']);
    //   if (payload.containsKey('mensaje'))
    //     print("mensaje ${payload['mensaje']}");
    // });
  }
}
