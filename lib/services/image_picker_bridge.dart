import 'dart:typed_data';

import 'image_picker_bridge_stub.dart'
    if (dart.library.html) 'image_picker_bridge_web.dart'
    if (dart.library.io) 'image_picker_bridge_mobile.dart';

class PickedImageData {
  PickedImageData({required this.bytes, this.mimeType});

  final Uint8List bytes;
  final String? mimeType;
}

Future<PickedImageData?> pickImageData() => pickImageDataImpl();
