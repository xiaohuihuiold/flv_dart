import 'package:flv_dart/src/info/flv_tag.dart';

class FLVTagAudio extends FLVTag {
  int soundFormat;
  int soundRate;
  int soundSize;
  int soundType;

  int aacPacketType;

  dynamic data;
}

class AudioSpecificConfig{

}