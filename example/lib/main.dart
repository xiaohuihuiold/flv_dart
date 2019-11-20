import 'package:flutter/material.dart';
import 'package:flv_dart/flv_dart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Null> _onFrame(_) async {
    FLVLoader loader = FLVLoader();
    loader.onNALUCallbacks.add((nalu) {
      print(nalu);
    });
    loader.loadFromPath('/storage/emulated/0/0.flv');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FLV'),
      ),
    );
  }
}
