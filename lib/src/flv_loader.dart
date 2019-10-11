import 'dart:ffi';
import 'dart:io';

import 'dart:typed_data';

import 'package:flv_dart/flv_dart.dart';

class FLVLoader {
  int offset = 0;
  AVCDecoderConfigurationRecord avcDecoderConfigurationRecord;

  Future<FLVData> loadFromPath(String path) async {
    File file = File(path);
    if (!await file.exists()) {
      print('文件"$path"不存在');
      return null;
    }
    print('文件:$path');
    RandomAccessFile randomAccessFile = await file.open();
    int length = await randomAccessFile.length();
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
    // 因为最后四个字节代表最后一个tag的大小,所以减去4
    while (offset < length - 4) {
      flvData.addTag(await parseTag(randomAccessFile));
    }
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
        (await file.read(1)).buffer.asByteData().getUint8(0) /* & 0x1f*/);
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
        // 暂时跳过音频标签
        offset += dataSize;
        break;
      case TAGType.video:
        FLVTagVideo tagVideo = await parseVideo(
          file,
          FLVTagVideo()
            ..previousSize = previousSize
            ..type = type
            ..dataSize = dataSize
            ..timeStamp = timeStamp
            ..streamsId = streamsId,
        );
        return tagVideo;
        break;
      case TAGType.script:
        FLVTagScript tagScript = await parseScript(
          file,
          FLVTagScript()
            ..previousSize = previousSize
            ..type = type
            ..dataSize = dataSize
            ..timeStamp = timeStamp
            ..streamsId = streamsId,
        );
        // 填充元数据
        if ((tagScript.scripts?.length ?? 0) > 0) {
          tagScript.metaData = FLVMetaData.fromMap(tagScript.scripts[0]);
        }
        return tagScript;
      case TAGType.unknown:
        return null;
    }
    return null;
  }

  Future<FLVTagScript> parseScript(
      RandomAccessFile file, FLVTagScript tagScript) async {
    int startOffset = offset;
    while (offset - startOffset < tagScript.dataSize) {
      // 获取type
      await file.setPosition(offset);
      int type = (await file.read(1)).buffer.asByteData().getUint8(0);
      offset += 1;
      tagScript.add(await FLVTagScriptParser.parseFromType(this, file, type));
    }
    return tagScript;
  }

  Future<FLVTagVideo> parseVideo(
      RandomAccessFile file, FLVTagVideo tagVideo) async {
    int startOffset = offset;
    /*while (offset - startOffset < tagVideo.dataSize) {
      
    }*/
    // video header
    await file.setPosition(offset);
    int header = (await file.read(1))[0];
    offset += 1;
    tagVideo.frameType = (header >> 4) & 0x0f;
    tagVideo.codecId = header & 0x0f;

    // avc packet type
    await file.setPosition(offset);
    int avcPacketType = (await file.read(1)).buffer.asByteData().getUint8(0);
    offset += 1;
    tagVideo.avcPacketType = avcPacketType;

    // composition time
    await file.setPosition(offset);
    Uint8List sizeBytes = (await file.read(3));
    offset += 3;
    Uint8List sizeBytesA = Uint8List(4);
    sizeBytesA[0] = 0;
    sizeBytesA[1] = sizeBytes[0];
    sizeBytesA[2] = sizeBytes[1];
    sizeBytesA[3] = sizeBytes[2];
    tagVideo.compositionTime = sizeBytesA.buffer.asByteData().getUint32(0);

    // data
    switch (tagVideo.avcPacketType) {
      case 0:
        tagVideo.data =
            await FLVTagVideoParser.parseAVCDecoderConfig(this, file);
        avcDecoderConfigurationRecord =
            tagVideo.data as AVCDecoderConfigurationRecord;
        break;
      case 1:
        print('解析NALU');
        await FLVTagVideoParser.parseAVCNALU(this, file, tagVideo);
        break;
    }

    return tagVideo;
  }
}

/// flv video标签解析
class FLVTagVideoParser {
  static Future<AVCDecoderConfigurationRecord> parseAVCDecoderConfig(
      FLVLoader loader, RandomAccessFile file) async {
    AVCDecoderConfigurationRecord record = AVCDecoderConfigurationRecord();

    // version
    await file.setPosition(loader.offset);
    int version = (await file.read(1)).buffer.asByteData().getUint8(0);
    loader.offset += 1;
    record.configurationVersion = version;

    // sps[1-3]
    await file.setPosition(loader.offset);
    Uint8List sps = await file.read(3);
    loader.offset += 3;
    record.avcProfileIndication = sps[0];
    record.profileCompatibility = sps[1];
    record.avcLevelIndication = sps[2];

    // NALUnitLength
    await file.setPosition(loader.offset);
    int lengthSizeMinusOne =
        (await file.read(1)).buffer.asByteData().getUint8(0) & 0x03;
    loader.offset += 1;
    record.lengthSizeMinusOne = lengthSizeMinusOne;

    // sps length
    await file.setPosition(loader.offset);
    int spsLength = (await file.read(1)).buffer.asByteData().getUint8(0) & 0x1f;
    loader.offset += 1;
    record.numOfSequenceParameterSets = spsLength;

    // get sps
    for (int i = 0; i < spsLength; i++) {
      await file.setPosition(loader.offset);
      int length = (await file.read(2)).buffer.asByteData().getUint16(0);
      loader.offset += 2;
      for (int k = 0; k < length; k++) {
        await file.setPosition(loader.offset);
        int sps = (await file.read(1)).buffer.asByteData().getUint8(0);
        loader.offset += 1;
        record.addSPS(sps);
      }
    }

    // pps length
    await file.setPosition(loader.offset);
    int ppsLength = (await file.read(1)).buffer.asByteData().getUint8(0);
    loader.offset += 1;
    record.numOfPictureParameterSets = ppsLength;

    // get pps
    for (int i = 0; i < ppsLength; i++) {
      await file.setPosition(loader.offset);
      int length = (await file.read(2)).buffer.asByteData().getUint16(0);
      loader.offset += 2;
      for (int k = 0; k < length; k++) {
        await file.setPosition(loader.offset);
        int pps = (await file.read(1)).buffer.asByteData().getUint8(0);
        loader.offset += 1;
        record.addPPS(pps);
      }
    }

    return record;
  }

  static Future parseAVCNALU(
      FLVLoader loader, RandomAccessFile file, FLVTagVideo tagVideo) async {
    int startOffset = loader.offset;
    loader.offset += tagVideo.dataSize - 5;
    return;
    print(loader.offset);
    while ((loader.offset - startOffset) < tagVideo.dataSize) {
      await file.setPosition(loader.offset);
      int length = (await file.read(
                  loader.avcDecoderConfigurationRecord.lengthSizeMinusOne + 1))
              .buffer
              .asByteData()
              .getUint32(0) >>
          8;
      loader.offset += loader.avcDecoderConfigurationRecord.lengthSizeMinusOne;

      await file.setPosition(loader.offset);
      Uint8List bytes = await file.read(length);
      loader.offset += length;
      String str = '';
      bytes.forEach((e) {
        str += e.toRadixString(16) + ',';
      });
      print(str);
      print('');
    }
  }
}

/// flv script标签解析
class FLVTagScriptParser {
  static Future<int> getType(FLVLoader loader, RandomAccessFile file) async {
    await file.setPosition(loader.offset);
    int type = (await file.read(1)).buffer.asByteData().getUint8(0);
    loader.offset += 1;
    return type;
  }

  static Future<dynamic> parseFromType(
      FLVLoader loader, RandomAccessFile file, int type) async {
    switch (type) {
      case 0:
        return await parseDouble(loader, file);
      case 1:
        return await parseBool(loader, file);
      case 2:
        return await parseString(loader, file);
      case 3:
        return await parseObject(loader, file);
      case 4:
        break;
      case 5:
        break;
      case 6:
        break;
      case 7:
        break;
      case 8:
        return await parseEcmaArray(loader, file);
      case 9:
        return FLVTagScriptType.end;
      case 10:
        return await parseArray(loader, file);
      case 11:
        return await parseDate(loader, file);
      case 12:
        return await parseLongString(loader, file);
    }
    return null;
  }

  static Future<List> parseArray(
      FLVLoader loader, RandomAccessFile file) async {
    await file.setPosition(loader.offset);
    int length = (await file.read(4)).buffer.asByteData().getUint32(0);
    loader.offset += 4;
    List list = List();
    for (int i = 0; i < length; i++) {
      list.add(await parseFromType(loader, file, await getType(loader, file)));
    }
    return list;
  }

  static Future<int> parseDate(FLVLoader loader, RandomAccessFile file) async {
    await file.setPosition(loader.offset);
    int data = (await file.read(8)).buffer.asByteData().getUint64(0);
    loader.offset += 8;
    return data;
  }

  static Future<Map<String, dynamic>> parseEcmaArray(
      FLVLoader loader, RandomAccessFile file) async {
    await file.setPosition(loader.offset);
    int length = (await file.read(4)).buffer.asByteData().getUint32(0);
    loader.offset += 4;
    Map<String, dynamic> map = Map();
    for (int i = 0; i < length; i++) {
      Map<String, dynamic> obj = await parseObject(loader, file);
      map.addAll(obj);
      i = obj?.length ?? i;
    }
    return map;
  }

  static Future<Map<String, dynamic>> parseObject(
      FLVLoader loader, RandomAccessFile file) async {
    Map<String, dynamic> map = Map();
    bool objEnd = false;
    while (!objEnd) {
      String key = await parseString(loader, file);
      dynamic value =
          await parseFromType(loader, file, await getType(loader, file));
      if (value == FLVTagScriptType.end) {
        return map;
      }
      map[key] = value;
    }
    return map;
  }

  static Future<String> parseString(
      FLVLoader loader, RandomAccessFile file) async {
    await file.setPosition(loader.offset);
    int length = (await file.read(2)).buffer.asByteData().getUint16(0);
    loader.offset += 2;

    await file.setPosition(loader.offset);
    Uint8List data = await file.read(length);
    loader.offset += length;
    return String.fromCharCodes(data);
  }

  static Future<String> parseLongString(
      FLVLoader loader, RandomAccessFile file) async {
    await file.setPosition(loader.offset);
    int length = (await file.read(4)).buffer.asByteData().getUint32(0);
    loader.offset += 4;

    await file.setPosition(loader.offset);
    Uint8List data = await file.read(length);
    loader.offset += length;
    return String.fromCharCodes(data);
  }

  static Future<bool> parseBool(FLVLoader loader, RandomAccessFile file) async {
    await file.setPosition(loader.offset);
    int data = (await file.read(1)).buffer.asByteData().getUint8(0);
    loader.offset += 1;
    return data == 1;
  }

  static Future<double> parseDouble(
      FLVLoader loader, RandomAccessFile file) async {
    await file.setPosition(loader.offset);
    double data = (await file.read(8)).buffer.asByteData().getFloat64(0);
    loader.offset += 8;
    return data;
  }
}
