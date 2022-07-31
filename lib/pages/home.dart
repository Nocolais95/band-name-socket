import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/band.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 7),
    Band(id: '3', name: 'Beatles', votes: 9),
    Band(id: '4', name: 'Survivor', votes: 3),
    Band(id: '5', name: 'Bon Jovi', votes: 4),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) => _bandTile(bands[i])),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: () => addNewBand(),
      ),
    );
  }

  Widget _bandTile(Band bands) {
    return Dismissible(
      direction: DismissDirection.startToEnd,
      key: Key(bands.id),
      onDismissed: (direction) {
        print('direction: $direction');
        print('id: ${bands.id}');
        //TODO: llamar el borrado del server
      },
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
        onTap: () {
          print(bands.name);
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
          );
        },
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
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
        );
      },
    );
  }

  void addBandList(String name) {
    print(name);
    if (name.length > 1) {
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }

    Navigator.pop(context);
  }
}
