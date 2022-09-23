import 'dart:io';

import 'package:band_names/services/socket_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../models/band.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketServices = Provider.of<SocketServices>(context, listen: false);
    socketServices.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketServices = Provider.of<SocketServices>(context, listen: false);
    socketServices.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketServices = Provider.of<SocketServices>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketServices.serverStatus == ServerStatus.onLine)
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: () => addNewBand(),
      ),
    );
  }

  Widget _bandTile(Band bands) {
    final socketServices = Provider.of<SocketServices>(context, listen: false);

    return Dismissible(
      direction: DismissDirection.startToEnd,
      key: Key(bands.id),
      onDismissed: (_) => socketServices.emit('delete-band', {'id': bands.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.8),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            // substring para poner solo las dos primeras letras
            bands.name.substring(0, 2),
          ),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(bands.name),
        trailing: Text(
          '${bands.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketServices.socket.emit('vote-band', {'id': bands.id}),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('New band name: '),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              textColor: Colors.blue,
              elevation: 5,
              child: Text('Add'),
              onPressed: () => addBandList(textController.text),
            ),
          ],
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('New band name: '),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Add'),
            onPressed: () => addBandList(textController.text),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Dismiss'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void addBandList(String name) {
    if (name.length > 1) {
      final socketServices =
          Provider.of<SocketServices>(context, listen: false);
      socketServices.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  // Mostrar grafica
  Widget _showGraph() {
    Map<String, double> dataMap = {};
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue,
      Colors.red,
      Colors.red.shade200,
      Colors.yellow,
      Colors.blue.shade200,
      Colors.yellow.shade200,
      Colors.pink,
      Colors.pink.shade200,
      Colors.green,
      Colors.green.shade200,
    ];
    // Null Safety
    return dataMap.isNotEmpty
        ? SizedBox(
            width: double.infinity,
            height: 200,
            child: PieChart(
              dataMap: dataMap,
              animationDuration: const Duration(milliseconds: 800),
              chartRadius: MediaQuery.of(context).size.width / 1.1,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.disc, // or ring
              legendOptions: const LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.left,
                showLegends: true,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValueBackground: true,
                chartValueBackgroundColor: Colors.white54,
                showChartValues: true,
                showChartValuesInPercentage: true,
                showChartValuesOutside: false,
                decimalPlaces: 1,
              ),
            ))
        : const LinearProgressIndicator();
  }
}
