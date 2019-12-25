class H264Parser {
  List<int> sps;
  List<int> pps;

  Future parseH264(List<int> sps, List<int> pps, List<int> nalu) async {
    this.sps = sps;
    this.pps = pps;
    int headerType = nalu[0];
    nalu = nalu.sublist(1);
    if (headerType != 0x65) {
      return;
    }
    // I片
    switch (headerType) {
      case 0x65:
        // IDR帧
        print('IDR帧');
        print(nalu.map<String>((e)=>e.toRadixString(16).toUpperCase()));
        break;
      case 0x61:
        // I帧
        print('I帧');
        print(nalu);
        break;
      case 0x41:
        // P帧
        print('P帧');
        print(nalu);
        break;
      case 0x01:
        // B帧
        print('B帧');
        print(nalu);
        break;
      case 0x06:
        // SEI信息
        print('SEI信息');
        print(nalu);
        break;
      default:
        print('未知: ${headerType?.toRadixString(16)}');
        break;
    }
  }
}
