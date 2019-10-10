class FLVMetaData {
  String creator;
  String description;
  String metaDataCreator;

  bool hasKeyframes;
  bool hasVideo;
  bool hasAudio;
  bool hasMetadata;
  bool canSeekToEnd;

  int duration;
  int dataSize;

  int videoSize;
  double frameRate;
  double videoDataRate;
  int videoCodecId;
  int width;
  int height;

  int audioSize;
  double audioDataRate;
  int audioCodecId;
  double audioSampleRate;
  int audioSampleSize;

  bool stereo;
  int fileSize;

  int lastTimestamp;
  int lastKeyframeTimestamp;
  int lastKeyframeLocation;

  final FLVMetaKeyFrames keyframes;

  FLVMetaData({
    this.creator,
    this.description,
    this.metaDataCreator,
    this.hasKeyframes,
    this.hasVideo,
    this.hasAudio,
    this.hasMetadata,
    this.canSeekToEnd,
    this.duration,
    this.dataSize,
    this.videoSize,
    this.frameRate,
    this.videoDataRate,
    this.videoCodecId,
    this.width,
    this.height,
    this.audioSize,
    this.audioDataRate,
    this.audioCodecId,
    this.audioSampleRate,
    this.audioSampleSize,
    this.stereo,
    this.fileSize,
    this.lastTimestamp,
    this.lastKeyframeTimestamp,
    this.lastKeyframeLocation,
    this.keyframes,
  });

  factory FLVMetaData.fromMap(Map<String, dynamic> map) {
    return FLVMetaData(
      creator: map['creator'] as String,
      description: map['description'] as String,
      metaDataCreator: map['metadatacreator'] as String,
      hasKeyframes: map['hasKeyframes'] as bool,
      hasVideo: map['hasVideo'] as bool,
      hasAudio: map['hasAudio'] as bool,
      hasMetadata: map['hasMetadata'] as bool,
      canSeekToEnd: map['canSeekToEnd'] as bool,
      duration: (((map['duration'] as double) ?? 0.0) * 1000.0).toInt(),
      dataSize: ((map['datasize'] as double) ?? 0.0).toInt(),
      videoSize: ((map['videosize'] as double) ?? 0.0).toInt(),
      frameRate: (map['framerate']) ?? 0.0,
      videoDataRate: (map['videodatarate']) ?? 0.0,
      videoCodecId: ((map['videocodecid'] as double) ?? 0.0).toInt(),
      width: ((map['width'] as double) ?? 0.0).toInt(),
      height: ((map['height'] as double) ?? 0.0).toInt(),
      audioSize: ((map['audiosize'] as double) ?? 0.0).toInt(),
      audioDataRate: (map['audiodatarate']) ?? 0.0,
      audioCodecId: ((map['audiocodecid'] as double) ?? 0.0).toInt(),
      audioSampleRate: (map['audiosamplerate']) ?? 0.0,
      audioSampleSize: ((map['audiosamplesize'] as double) ?? 0.0).toInt(),
      stereo: map['stereo'] as bool,
      fileSize: ((map['filesize'] as double) ?? 0.0).toInt(),
      lastTimestamp:
          (((map['lasttimestamp'] as double) ?? 0.0) * 1000.0).toInt(),
      lastKeyframeTimestamp:
          (((map['lastkeyframetimestamp'] as double) ?? 0.0) * 1000.0).toInt(),
      lastKeyframeLocation:
          ((map['lastkeyframelocation'] as double) ?? 0.0).toInt(),
      keyframes: map['keyframes'] == null
          ? null
          : FLVMetaKeyFrames.fromMap(map['keyframes'] as Map),
    );
  }
}

class FLVMetaKeyFrames {
  List<int> filePositions;
  List<int> times;

  FLVMetaKeyFrames({this.filePositions, this.times});

  factory FLVMetaKeyFrames.fromMap(Map map) {
    List<dynamic> list = map['filepositions'] as List<dynamic>;
    List<int> filePositions = List<int>.generate(list?.length ?? 0, (index) {
      return (list[index] as double).toInt();
    });
    list = map['times'] as List<dynamic>;
    List<int> times = List<int>.generate(list?.length ?? 0, (index) {
      return ((list[index] as double) * 1000.0).toInt();
    });
    return FLVMetaKeyFrames(filePositions: filePositions, times: times);
  }
}
