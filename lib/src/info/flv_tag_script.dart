import 'package:flv_dart/flv_dart.dart';

enum FLVTagScriptType {
  double,
  boolean,
  string,
  object,
  moveClip,
  typeNull,
  undefined,
  reference,
  map,
  end,
  array,
  date,
  longString,
  unknown,
}

class FLVTagScript extends FLVTag {
  List<dynamic> scripts;

  void add(dynamic script) {
    if (script == null) {
      return;
    }
    if (scripts == null) {
      scripts = List();
    }
    scripts.add(script);
  }

  @override
  String toString() {
    return '''======FLV Script======
| previousSize: $previousSize
| type: $type
| dataSize: $dataSize
| timeStamp: $timeStamp
| streamsId: $streamsId
| ------scripts------
| ${() {
      String str = '';
      scripts?.forEach((e) {
        str += e?.toString();
        str += "\n";
      });
      return str;
    }()}
====================\n''';
  }
}
