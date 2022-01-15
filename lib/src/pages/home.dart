import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:flutter_sockets_bands_app/src/models/band.dart';
import 'package:flutter_sockets_bands_app/src/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: "1", name: "Metalica", votes: 5),
    // Band(id: "2", name: "Queen", votes: 3),
    // Band(id: "3", name: "Morat", votes: 4),
    // Band(id: "4", name: "Pasabordo", votes: 4),
  ];

  @override
  void initState() {
    // TODO: implement initState
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on("active-bands", _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SocketService socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bands Names",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation: 1,
        onPressed: _addNewBand,
      ),
    );
  }

  void _addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('New band name:'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              child: const Text("Add"),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => _addBandToList(textController.text),
            )
          ],
        ),
      );
    }
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Add"),
              onPressed: () => _addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text("dismiss"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  _addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit("add-band", {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Delete Band",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      onDismissed: (_) =>
          socketService.socket.emit("delete-band", {'id': band.id}),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text("${band.votes}", style: const TextStyle(fontSize: 20)),
        onTap: () => socketService.socket.emit("vote-band", {'id': band.id}),
      ),
    );
  }

  _showGraph() {
    Map<String, double> dataMap = {};
    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }

    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32.0,
        chartValuesOptions: const ChartValuesOptions(
          showChartValuesInPercentage: true,
          chartValueBackgroundColor: Colors.transparent,
        ),
        chartRadius: MediaQuery.of(context).size.width / 2.7,
      ),
    );
  }
}
