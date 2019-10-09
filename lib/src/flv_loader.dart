import 'dart:ffi';
import 'dart:io';

import 'dart:typed_data';

import 'package:flv_dart/flv_dart.dart';

class FLVLoader {
  int offset = 0;

  Future<FLVData> loadFromPath(String path) async {
    File file = File(path);
    if (!await file.exists()) {
      print('文件"$path"不存在');
      return null;
    }
    print('文件:$path');
    RandomAccessFile randomAccessFile = await file.open();
    // 创建flv数据类
    FLVData flvData = FLVData();

    offset = 0;
    // 解析flv头
    flvData.header = await parseHeader(randomAccessFile);
    if (flvData.header == null) {
      print('文件"$path"不是flv格式的文件');
      return null;
    }

    // 解析标签
    flvData.addTag(await parseTag(randomAccessFile));

    return flvData;
  }

  Future<FLVHeader> parseHeader(RandomAccessFile file) async {
    FLVHeader header = FLVHeader();

    // 获取type
    await file.setPosition(offset);
    Uint8List type = await file.read(3);
    offset += 3;
    header.type = String.fromCharCodes(type);
    if (header.type != 'FLV') {
      return null;
    }

    // 获取flv版本号
    await file.setPosition(offset);
    int version = (await file.read(1))[0];
    offset += 1;
    header.version = version;

    // 获取flv流信息
    await file.setPosition(offset);
    int info = (await file.read(1))[0];
    offset += 1;
    header.hasAudio = (info & 0x04) >> 2 == 1;
    header.hasVideo = (info & 0x01) == 1;

    // 获取长度
    await file.setPosition(offset);
    Uint8List length = await file.read(4);
    offset += 4;
    header.length = length.buffer.asByteData().getUint32(0);

    return header;
  }

  Future<FLVTag> parseTag(RandomAccessFile file) async {
    int previousSize;
    TAGType type;
    int dataSize;
    int timeStamp;
    int streamsId;

    // 获取previous
    await file.setPosition(offset);
    previousSize = (await file.read(4)).buffer.asByteData().getUint32(0);
    offset += 4;

    // 获取type
    await file.setPosition(offset);
    type = FLVTag.int2Type(
        (await file.read(1)).buffer.asByteData().getUint8(0) & 0x1f);
    offset += 1;

    // 获取data大小
    await file.setPosition(offset);
    Uint8List sizeBytes = (await file.read(3));
    offset += 3;
    Uint8List sizeBytesA = Uint8List(4);
    sizeBytesA[0] = 0;
    sizeBytesA[1] = sizeBytes[0];
    sizeBytesA[2] = sizeBytes[1];
    sizeBytesA[3] = sizeBytes[2];
    dataSize = sizeBytesA.buffer.asByteData().getUint32(0);

    // 获取时间戳
    await file.setPosition(offset);
    Uint8List timeBytes = (await file.read(4));
    offset += 4;
    Uint8List timeBytesA = Uint8List(4);
    timeBytesA[0] = timeBytes[3];
    timeBytesA[1] = timeBytes[0];
    timeBytesA[2] = timeBytes[1];
    timeBytesA[3] = timeBytes[2];
    timeStamp = timeBytesA.buffer.asByteData().getUint32(0);

    // 获取streamid
    await file.setPosition(offset);
    Uint8List idBytes = (await file.read(3));
    offset += 3;
    Uint8List idBytesA = Uint8List(4);
    idBytesA[0] = 0;
    idBytesA[1] = idBytes[0];
    idBytesA[2] = idBytes[1];
    idBytesA[3] = idBytes[2];
    streamsId = idBytesA.buffer.asByteData().getUint32(0);

    switch (type) {
      case TAGType.audio:
        break;
      case TAGType.video:
        break;
      case TAGType.script:
        return await parseScript(
          file,
          FLVTagScript()
            ..previousSize = previousSize
            ..type = type
            ..dataSize = dataSize
            ..timeStamp = timeStamp
            ..streamsId = streamsId,
        );
      case TAGType.unknown:
        return null;
    }
    return null;
  }

  Future<FLVTagScript> parseScript(
      RandomAccessFile file, FLVTagScript tagScript) async {
    return tagScript;
  }
}
