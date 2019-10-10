import 'package:flv_dart/flv_dart.dart';

class FLVTagVideo extends FLVTag {
  int frameType;
  int codecId;

  int avcPacketType;
  int compositionTime;

  dynamic data;
}

class AVCDecoderConfigurationRecord {
  int configurationVersion;
  int avcProfileIndication;
  int profileCompatibility;
  int avcLevelIndication;
  int lengthSizeMinusOne;
  int numOfSequenceParameterSets;
  int numOfPictureParameterSets;
  List<int> sequenceParameterSetNALUnits;
  List<int> pictureParameterSetNALUnits;

  void addSPS(int sps) {
    if (sequenceParameterSetNALUnits == null) {
      sequenceParameterSetNALUnits = List();
    }
    sequenceParameterSetNALUnits.add(sps);
  }

  void addPPS(int pps) {
    if (pictureParameterSetNALUnits == null) {
      pictureParameterSetNALUnits = List();
    }
    pictureParameterSetNALUnits.add(pps);
  }
}
