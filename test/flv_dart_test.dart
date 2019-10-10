import 'package:flutter_test/flutter_test.dart';

import 'package:flv_dart/flv_dart.dart';

void main() {
  test('load flv', () async {
    FLVData flvData = await FLVLoader().loadFromPath('/home/xhh/视频/test.flv');
    FLVHeader header = flvData.header;
    List<FLVTag> tags = flvData.flvTags;

    print('''======FLV Header======
| type: ${header?.type}
| version: ${header?.version}
| hasAudio: ${header?.hasAudio}
| hasVideo: ${header?.hasVideo}
| length: ${header?.length}
''');

    tags?.forEach((tag) {
      print('''======FLV Script======
| previousSize: ${tag?.previousSize}
| type: ${tag?.type}
| dataSize: ${tag?.dataSize}
| timeStamp: ${tag?.timeStamp}
| streamsId: ${tag?.streamsId}''');
      if (tag is FLVTagScript) {
        printScriptTag(tag);
      }
    });
  }, timeout: Timeout(Duration(days: 1)));
}

void printScriptTag(FLVTagScript tagScript) {
  if (tagScript == null) {
    return;
  }
  print('| -${tagScript.name}');
  printList(tagScript.scripts, 1);
}

void printList(List list, int depth) {
  if (list == null) {
    return;
  }
  list.forEach((e) {
    if (e is List) {
      printList(e, depth + 1);
      return;
    } else if (e is Map) {
      printMap(e, depth + 1);
      return;
    }
    print('| ${'-' * depth} $e');
  });
}

void printMap(Map map, int depth) {
  if (map == null) {
    return;
  }
  map.forEach((key, value) {
    if (value is List) {
      print('| ${'-' * depth} $key: ');
      printList(value, depth + 1);
      return;
    } else if (value is Map) {
      print('| ${'-' * depth} $key: ');
      printMap(value, depth + 1);
      return;
    }
    print('| ${'-' * depth} $key: $value');
  });
}
