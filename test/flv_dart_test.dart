import 'package:flutter_test/flutter_test.dart';

import 'package:flv_dart/flv_dart.dart';

void main() {
  test('load flv', () async{
    FLVData flvData = await FLVLoader().loadFromPath('/home/xhh/视频/test.flv');
    print(flvData);
  });
}
