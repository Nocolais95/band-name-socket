import 'package:band_names/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketServices = Provider.of<SocketServices>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ServerStatus: ${socketServices.serverStatus}'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () {
          socketServices.socket.emit('emitir-mensaje', {
            'nombre': 'Maxis',
            'mensaje': 'Hola mundo!!',
          });
        },
      ),
    );
  }
}
