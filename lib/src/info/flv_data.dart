import 'package:flv_dart/flv_dart.dart';

class FLVData {
  FLVHeader header;
  List<FLVTag> flvTags;

  void addTag(FLVTag tag) {
    if (tag == null) {
      return;
    }
    if (flvTags == null) {
      flvTags = List();
    }
    flvTags.add(tag);
  }

  @override
  String toString() {
    print(header);
    flvTags?.forEach((tag) {
      print(tag);
    });
    return super.toString();
  }
}
