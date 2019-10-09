class FLVHeader {
  String type;
  int version;
  bool hasAudio;
  bool hasVideo;
  int length;

  @override
  String toString() {
    return '''======FLV文件头======
| type: $type
| version: $version
| hasAudio: $hasAudio
| hasVideo: $hasVideo
| length: $length
====================\n''';
  }
}
