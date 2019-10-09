enum TAGType {
  audio,
  video,
  script,
  unknown,
}

abstract class FLVTag {
  int previousSize;
  TAGType type;
  int dataSize;
  int timeStamp;
  int streamsId;

  static TAGType int2Type(int type) {
    switch (type) {
      case 0x08:
        return TAGType.audio;
      case 0x09:
        return TAGType.video;
      case 0x12:
        return TAGType.script;
    }
    return TAGType.unknown;
  }

  static int type2Int(TAGType type) {
    switch (type) {
      case TAGType.audio:
        return 0x08;
      case TAGType.video:
        return 0x09;
      case TAGType.script:
        return 0x12;
      case TAGType.unknown:
        return -1;
    }
    return -1;
  }
}
