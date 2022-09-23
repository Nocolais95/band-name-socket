import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Creamos una enumeracion para manejar los estados del server
enum ServerStatus {
  onLine,
  offLine,
  conecting,
}

class SocketServices with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.conecting;
  IO.Socket? _socket;

  ServerStatus get serverStatus => _serverStatus;

  IO.Socket get socket => _socket!;
  Function get emit => _socket!.emit;

  SocketServices() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    _socket = IO.io('http://192.168.100.5:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket!.onConnect((_) {
      _serverStatus = ServerStatus.onLine;
      notifyListeners();
    });
    _socket!.onDisconnect((_) {
      _serverStatus = ServerStatus.offLine;
      notifyListeners();
    });
    // socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo-mensaje:');
    //   print('nombre: ' + payload['nombre']);
    //   print('mensaje: ' + payload['mensaje']);
    //   print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay');
    // });
  }
}
