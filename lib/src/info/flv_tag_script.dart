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
  objectAndMark,
  array,
  date,
  longString,
  unknown,
}

class FLVTagScript extends FLVTag {
  @override
  String toString() {
    return '''======FLV Script======
| previousSize: $previousSize
| type: $type
| dataSize: $dataSize
| timeStamp: $timeStamp
| streamsId: $streamsId
====================\n''';
  }
}
